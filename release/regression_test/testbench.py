from os.path import join, dirname
import os, sys, subprocess

# Disable terminal output
FNULL = open(os.devnull, 'w')


#=============================================================================================
#
# Methods
#
#=============================================================================================

class Testbench:

    def __init__(self):
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
      print("\nTestbench arguments:")
      print("-V enable terminal output")
      print("-MODELSIM set modelsim simulator (default)")
      print("-RIVIERA set Aldec Riviera Pro simulator\n")
      sys.exit(0)


    def set_library(self, library):
      self.library = library.lower()

    def get_library(self):
      return self.library

    def set_simulator(self, simulator):
      self.simulator = simulator.upper()

    def set_tb_name(self, tb):
      self.tb = tb.lower()

    def get_tb_name(self):
      return self.tb

    def set_cleanup(self, mode):
      self.do_cleanup = mode


    def reset_counters(self):
      self._num_tests_run = 0
      self._num_failing_tests = 0

    def get_counters(self):
      return self.num_tests_run, self.num_failing_tests

    def get_num_tests_run(self):
      return self.num_tests_run

    def get_num_failing_tests(self):
      return self.num_failing_tests


    def add_test(self, test):
      self.tests.append(test)

    def add_tests(self, tests):
      for test in tests:
        self.tests.append(test)

    def get_tests(self):
      return self.tests

    def remove_tests(self):
      self.tests = []


    def remove_configs(self):
      self.configs = []

    def add_config(self, config):
      self.configs.append(config)

    def set_configs(self, configs):
      self.remove_configs()
      for config in configs:
        self.add_config(config)

    def get_configs(self):
      return self.configs


    # Script arguments
    def check_arguments(self, args):
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
      print("Setting environment SIMULATOR=%s" %(self.simulator))
      self.env_var = os.environ.copy()
      self.env_var["SIMULATOR"] = self.simulator

    def get_simulator(self):
      return self.simulator


    # Activate simulator with call
    def simulator_call(self, script_call):
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
    def set_compile_directives(self, comdir):
      self.compdir = compdir

    def get_compile_directives(self):
      return self.compdir

    # Compile DUT, testbench and dependencies
    def compile(self):
      self.set_simulator_variable()
      print("\nCompiling dependenies.")
      self.simulator_call("do ../internal_script/compile_dependencies.do")
      print("Compiling src.")
      self.simulator_call("do ../script/compile_src.do")
      print("Compiling testbench.")
      self.simulator_call("do ../internal_script/compile_tb.do")



    # Clean-up
    def cleanup(self, test):
      if (test != None) & (self.do_cleanup == True):
        os.remove(test + "_Alert.txt")
        os.remove(test + "_Log.txt")
        if os.path.isfile('transcript'):
          os.remove('transcript')




    # Check simulation results
    def check_result(self, filename):
      for line in open(filename, 'r'):
        if ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" in line:
          return True
      return False


    def increment_num_tests(self):
      self.num_tests_run += 1


    def increment_num_failing_tests(self):
      self.num_failing_tests += 1


    # Run simulations and check result
    def run_simulation(self):
      if len(self.tests) == 0: self.tests = ["All"]
      if len(self.configs) == 0: self.configs = [""]

      for test in self.tests:
      
        for config in self.configs:
          self.increment_num_tests()
          print("[%s] test=%s, config=%s : " % (self.tb, test, config), end='')

          script_call = 'do ../internal_script/run_simulation.do ' + self.library + ' ' + self.tb + ' ' + test + ' ' + config
          self.simulator_call(script_call)

          if self.check_result("%s_Log.txt" %(test)) == True:
            print("PASS")
            self.cleanup(test)
          else:
            print("FAILED")
            self.increment_num_failing_tests()

      self.remove_tests()


    def print_statistics(self):
      total = self.get_num_tests_run()
      failed = self.get_num_failing_tests()
      passed = (total - failed)
      print("Simulations done. Pass=%i, Fail=%i, Total=%i" %(passed, failed, total))
