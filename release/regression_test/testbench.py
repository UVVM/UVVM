from os.path import join, dirname
import os, sys, subprocess, glob

# Disable terminal output
FNULL = open(os.devnull, 'w')


#=============================================================================================
#
# Methods
#
#=============================================================================================

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
      self.num_tests_run = 0
      self.num_failing_tests = 0
      self.configs = []
      self.tests = []
      self.do_cleanup = True
      self.simulator = "MODELSIM"
      self.env_var = os.environ.copy()


    def print_help(self):
      """
      Prints a short usage description with command line arguments.
      """
      print("\nTestbench arguments:")
      print("-V enable terminal output")
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
      for arg in args:
        arg = arg.upper().split()

        if '-V' in arg:
          self.verbose = True
        if ('-ALDEC' or '-RIVIERA' or '-RIVIERAPRO') in arg:
          self.simulator = 'RIVIERAPRO'
        if ('-MODELSIM') in arg:
          self.simulator = 'MODELSIM'
        #if ('-?' or '?' or '-H' or '-HELP' in arg):
        #  self.print_help()        


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
    def simulator_call(self, script_call):
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

      if self.verbose == False:
        subprocess.call([cmd, '-c', '-do', script_call + ';exit'], env=self.env_var, stdout=FNULL, stderr=subprocess.PIPE)
      else:
        subprocess.call([cmd, '-c', '-do', script_call + ';exit'], env=self.env_var, stderr=subprocess.PIPE)


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
      print("\nCompiling dependencies...")
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
    def cleanup(self, test_name):
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
      for item in check_files:
        try:
          for line in open(item, 'r'):
            if ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" in line:
              return True
          return False
        except:
          print("Unable to find test result file: %s."  %(item))
          return False



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


    # Run simulations and check result
    def run_simulation(self):
      """
      Run testbench simulations with all specified tests and configurations.
      """
      if len(self.tests) == 0: self.tests = ["All"]
      if len(self.configs) == 0: self.configs = [""]

      for test_name in self.tests:
      
        for config in self.configs:
          self.increment_num_tests()
          print("[%s] test=%s, config=%s : " % (self.tb, test_name, config), end='')

          script_call = 'do ../internal_script/run_simulation.do ' + self.library + ' ' + self.tb + ' ' + test_name + ' ' + config
          self.simulator_call(script_call)

          if self.check_result(test_name) == True:
            print("PASS")
            self.cleanup(test_name)
          else:
            print("FAILED")
            self.increment_num_failing_tests()

      self.remove_tests()


    def print_statistics(self):
      """
      Print the simulation result statistics
      """
      total = self.get_num_tests_run()
      failed = self.get_num_failing_tests()
      passed = (total - failed)
      print("Simulations done. Pass=%i, Fail=%i, Total=%i" %(passed, failed, total))
