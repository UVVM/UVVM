import os
import sys
import subprocess
import glob
import shutil
import logging

# Disable terminal output
FNULL = open(os.devnull, 'w')



class Testbench:
    """
    Testbench class

    Testbench is used for building a simulation environment which will 
    run a testbench with defined tests and configurations.
    """


    def __init__(self):
      """
      Initializes the testbench object.

      """
      self.library  = None
      self.tb       = None
      self.verbose  = False
      self.gui_mode = False
      self.num_tests_run = 0
      self.num_failing_tests = 0
      self.configs = []
      self.tests = []
      self.exp_failing_testcase = []
      self.do_cleanup = True
      self.simulator = "MODELSIM"
      self.env_var = os.environ.copy()


    def print_help(self):
      """
      Prints a short usage description with command line arguments.
      """
      print("\nTestbench arguments:")
      print("-V enable terminal output")
      print("-G enable GUI mode")
      print("-MODELSIM set modelsim simulator (default)")
      print("-RIVIERA set Aldec Riviera Pro simulator\n")
      sys.exit(0)


    def set_library(self, library):
      """
      Sets the library name where the testbench is compiled to.

      Args:
        library (str): name of library
      """
      self.library = library.lower()

    def get_library(self):
      """
      Returns the library name where the testbench is compiled to.

      Returns:
        string: name of library
      """
      return self.library


    def set_simulator(self, simulator):
      """
      Sets the simulator used for running the testbench simulations.

      Args:
        simulator (str): name of simulator (modelsim, rivierapro)
      """
      self.simulator = simulator.upper()


    def set_tb_name(self, tb):
      """
      Sets the testbench entity name.

      Args:
        tb (str): testbench entity
      """
      self.tb = tb.lower()


    def get_tb_name(self):
      """
      Returns the testbench entity name.

      Returns:
        string: testbench entity name
      """
      return self.tb


    def set_cleanup(self, perform_cleanup):
      """
      Specifies if testbench object shall remove generated files.

      Args:
        perform_cleanup (bool): remove generated files selection
      """
      self.do_cleanup = perform_cleanup


    def reset_counters(self):
      """ 
      Reset number of run and failed tests.
      """
      self._num_tests_run = 0
      self._num_failing_tests = 0


    def get_counters(self):
      """
      Return the number of run and failing tests.

      Returns:
        list: the number of run tests and failing tests
      """
      return self.num_tests_run, self.num_failing_tests


    def get_num_tests_run(self):
      """
      Return the number of run tests

      Returns:
        int : the number of tests run.
      """
      return self.num_tests_run


    def get_num_failing_tests(self):
      """
      Return the number of failing tests

      Returns:
        int : the number of failing run.
      """
      return self.num_failing_tests


    def add_test(self, test):
      """
      Add a test defined in testbench. This test parameter will have to 
      mach a GC_TEST if statement in the testbench sequencer.

      Args:
        test (str): name of test 
      """
      self.tests.append(test)


    def add_tests(self, tests):
      """
      Add several tests defined in testbench. The tests in the tests parameter will
      have to mach the GC_TEST if statemens in the testbench sequncer.

      Ags:
        tests (list of str): name of tests
      """
      for test in tests:
        self.tests.append(test)


    def get_tests(self):
      """
      Return the defined tests to be run in testsbench sequencer.

      Returns:
        list: the name of defined tests
      """
      return self.tests


    def remove_tests(self):
      """
      Empty list of defined tests. 
      """
      self.tests = []


    def remove_configs(self):
      """
      Remove all defined testbench configurations.
      """
      self.configs = []


    def add_config(self, config):
      """
      Adds a testbench configuration, i.e. generics.

      Args:
        config (list): testbench configuration.
      """
      self.configs.append(config)


    def set_configs(self, configs):
      """
      Adds a set of testbench configurations, i.e. generics.

      Args:
        configs (list): testbench configurations.
      """
      self.remove_configs()
      for config in configs:
        self.add_config(config)


    def get_configs(self):
      """
      Get a list of all configurations

      Return:
        list: a list of all applied configuratoins.
      """
      return self.configs


    # Script arguments
    def check_arguments(self, args):
      """
      Check script calling arguments and set simulation
      behaviour, i.e. simulator, verbosity.

      Args:
        args (list): list of strings with arguments.
      """
      args = [arg.upper() for arg in args]

      for arg in args:
        arg = arg.split()

        if '-V' in arg:
          self.verbose = True
        
        if ('ALDEC' in arg) or ('RIVIERA' in arg) or ('RIVIERAPRO' in arg):
          self.simulator = 'RIVIERAPRO'
        elif ('-ALDEC' in arg) or ('-RIVIERA' in arg) or ('-RIVIERAPRO' in arg):
          self.simulator = 'RIVIERAPRO'
        
        if ('MODELSIM') in arg:
          self.simulator = 'MODELSIM'
        elif ('-MODELSIM') in arg:
          self.simulator = 'MODELSIM'
        
        if ('-G' in arg) or ('-GUI' in arg):
          self.gui_mode = True
        
        if ('-?' in arg) or ('?' in arg) or ('-H' in arg) or ('-HELP' in arg):
          self.print_help()     
          sys.exit(0)   



    def set_simulator_variable(self):
      """
      Set environment simulator variable for compile scripts.
      """
      self.env_var = os.environ.copy()
      self.env_var["SIMULATOR"] = self.simulator


    def select_simulator(self, simulator_name):
      """
      Select environment variable simulator for compile scripts.
      """
      self.simulator = simulator_name.upper()


    def get_simulator(self):
      """
      Get environment simulator variable for compile scripts.

      Return:
        str : simulator name
      """
      return self.simulator


    # Activate simulator with call
    def simulator_call(self, script_call, gui_mode=False):
      """
      Invoke simulator with given script call, and set environment variable for simulator selection.

      Args:
        script_call (str): argument to pass on with simulator call
      """
      if self.env_var["SIMULATOR"] == "MODELSIM":
        cmd = "vsim"
      elif self.env_var["SIMULATOR"] == "RIVIERAPRO":
        cmd = "vsimsa"
      else:
        print("Missing simulator!")
        print(self.env_var)
        sys.exit(1)

      terminal_run = '-c' if not(gui_mode) else ''

      if self.verbose == False:
        subprocess.call([cmd, terminal_run, '-do', script_call + ';exit'], env=self.env_var, stdout=FNULL, stderr=subprocess.PIPE)
      else:
        subprocess.call([cmd, terminal_run, '-do', script_call + ';exit'], env=self.env_var, stderr=subprocess.PIPE)


    # Set compile directives
    def set_compile_directives(self, compile_directives):
      """
      Set the simulator compilation directives

      To-do! Not implemented
      
      Args:
        compile_directives (list): strings of simulator compile directives
      """
      self.compile_directives = compile_directives


    def get_compile_directives(self):
      """
      Get the simulator compilation directives

      To-do! Not implemented

      Return:
        list: simulator compile dircetives
      """
      return self.compile_directives


    # Compile DUT, testbench and dependencies
    def compile(self):
      """
      Compile dependencie files, src files and testbench files
      """
      self.set_simulator_variable()
      print("Running with simulator : %s" %(self.simulator))
      print("Compiling dependencies...")
      self.simulator_call("do ../internal_script/compile_dependencies.do")
      print("Compiling src...")
      self.simulator_call("do ../script/compile_src.do")
      print("Compiling testbench...")
      self.simulator_call("do ../internal_script/compile_tb.do")



    def find_generated_test_files(self, test_name, pre_pattern="", post_pattern="", file_type="txt"):
      """
      Find files with specified file pattern

      Args:
        test_name (str): name of testbench test
        pre_pattern (str): any wildcard pattern to be included in front of test_name
        post_pattern (str): any wildcard pattern to be included after test_name
        file_type (str): type of file

      Return:
        list: matching file names as strings
      """
      search_string = pre_pattern + test_name + post_pattern + "." + file_type
      return glob.glob(search_string)


    # Clean-up
    def cleanup(self, test_name=None):
      """
      Remove generated files from test in testbench

      Args:
        test_name (str): name of test run in testbench
      """
      if (test_name != None) & (self.do_cleanup == True):
        remove_files = self.find_generated_test_files(test_name, post_pattern="*")
        for item in remove_files:
          if 'alert' or 'log' in item.lower():
            os.remove(item)

      if os.path.isfile('transcript'):
        os.remove('transcript')




    # Check simulation results
    def check_result(self, test_name):
      """
      Verify test result by examining the log file

      Args:
        test_name (str): name of test run in testbench
      """
      check_files = self.find_generated_test_files(test_name, post_pattern="*Log*")
      check_ok          = False
      num_failing_tests = 0
      is_log_file       = False

      for item in check_files:
        is_log_file = False
        check_ok    = False

        try:
          """ Read all lines and check if the file has an alert summary and simulation success. """
          for line in open(item, 'r'):

            # Detect alert summary line
            if "UVVM:      *** FINAL SUMMARY OF ALL ALERTS ***" in line:
              is_log_file = True
            # Detect simulation success if alert summary has been detected.
            if is_log_file:
              if ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" in line:
                check_ok = True
                continue
            
            # Detect any simulation stopping, i.e. failing test
            if "UVVM: Simulator has been paused as requested after" in line:
              num_failing_tests += 1
              check_ok = False
              continue



          # Was this a failing test?
          if not(check_ok):# and is_log_file:
            print("WARNING! Failing test: %s" %(item))
            num_failing_tests += 1

        except:
          print("Unable to find test result file: %s."  %(item))
          num_failing_tests += 1

      # Return simulation success result
      if (num_failing_tests > 0) or not(check_files):
        return False
      else:
        return True



    def increment_num_tests(self):
      """
      Increment the internal counter for number of run tests
      """
      self.num_tests_run += 1


    def increment_num_failing_tests(self):
      """
      Increment the internal counter for number of failing tests
      """
      self.num_failing_tests += 1


    def save_run(self, testbench, test_name, config):
      if test_name.lower() != 'all':
        foldername = test_name
      else:
        foldername = testbench
      if config:
        foldername += "_" + config
      #print("=====>>>  %s" %(foldername))
      pass


    def add_expected_failing_testcase(self, testcase):
      self.exp_failing_testcase.append(testcase.lower())

    def is_expected_failing_testcase(self, testcase):
      return testcase.lower() in self.exp_failing_testcase


    # Run simulations and check result
    def run_simulation(self, gui=False):
      """
      Run testbench simulations with all specified tests and configurations.
      """
      if len(self.tests) == 0: self.tests = ["All"]
      if len(self.configs) == 0: self.configs = [""]

      logging.basicConfig(level=logging.INFO, format='%(message)s')

      total_num_tests = len(self.tests)
      total_num_configs = len(self.configs)

      for test_idx, test_name in enumerate(self.tests):
        self.cleanup(test_name)
      
        for config_idx, config in enumerate(self.configs):
          self.cleanup(test_name)
          self.increment_num_tests()
          
          # Progress counter: (testcase / tot_testcases, config / total_configs)
          if config:
            run_str = ("(%d/%d, %d/%d)" %(test_idx+1, total_num_tests, config_idx+1, total_num_configs))
          else:
            run_str = ("(%d/%d)" %(test_idx+1, total_num_tests))

          test_string = run_str + " [" +  self.tb + "] test=" + test_name + " : "
          if config:
            test_string += config + " : "           

          script_call = 'do ../internal_script/run_simulation.do ' + self.library + ' ' + self.tb + ' ' + test_name + ' ' + config
          self.simulator_call(script_call, self.gui_mode)

          self.save_run(self.tb, test_name, config)
          if self.check_result(test_name) == True:
            if self.is_expected_failing_testcase(test_name):
              test_string += "FAILED"
              logging.warning(test_string)
              self.increment_num_failing_tests()
            else:
              test_string += "PASS"
              logging.info(test_string)
              self.cleanup(test_name)

          elif self.is_expected_failing_testcase(test_name):
            print("Expecting failing test: %s" %(test_name))
            test_string += "PASS"
            logging.info(test_string)
            self.cleanup(test_name)

          else:
            test_string += "FAILED"
            logging.warning(test_string)
            self.increment_num_failing_tests()

      self.remove_tests()


    def print_statistics(self):
      """
      Print the simulation result statistics
      """
      total = self.get_num_tests_run()
      failed = self.get_num_failing_tests()
      passed = (total - failed)
      print("Simulations done. Pass=%i, Fail=%i, Total=%i\n" %(passed, failed, total))
