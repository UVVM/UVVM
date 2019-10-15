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


    def set_library(self, library):
      self.library = library.lower()

    def get_library(self):
      return self.library


    def set_tb_name(self, tb):
      self.tb = tb.lower()

    def get_tb_name(self):
      return self.tb


    def reset_counters(self):
      self._num_tests_run = 0
      self._num_failing_tests = 0

    def get_counters(self):
      return self.num_tests_run, self.num_failing_tests

    def get_num_tests_run(self):
      return self.num_tests_run

    def get_num_failing_tests(self):
      return self.num_failing_tests


    def set_tests(self, tests):
      self.tests = tests

    def get_tests(self):
      return self.tests


    def set_configs(self, configs):
      self.configs = configs

    def get_configs(self):
      return self.configs


    # Script arguments
    def check_arguments(self, args):
      for arg in args:
        if arg.upper() == '-V':
          self.verbose = True


    # Activate simulator with call
    def simulator_call(self, simulator_call):
      if self.verbose == False:
        subprocess.call(['vsim', '-c', '-do', simulator_call + ';exit'], stdout=FNULL, stderr=subprocess.PIPE)
      else:
        subprocess.call(['vsim', '-c', '-do', simulator_call + ';exit'], stderr=subprocess.PIPE)


    # Compile DUT, testbench and dependencies
    def compile(self):
      print("\nCompiling and running tests:")
      simulator_call = 'do ../internal_script/compile_all.do'
      self.simulator_call(simulator_call)


    # Clean-up
    def clean_up(self, test):
      if test != None:
        os.remove(test + "_Alert.txt")
        os.remove(test + "_Log.txt")
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
      if len(self.tests) == 0: self.tests = ["ALL"]
      if len(self.configs) == 0: self.configs = [""]

      for test in self.tests:
      
        for config in self.configs:
          self.increment_num_tests()
          print("[%s] test=%s, config=%s : " % (self.tb, test, config), end='')

          script_call = 'do ../internal_script/run_simulation.do ' + self.library + ' ' + self.tb + ' ' + test + ' ' + config
          self.simulator_call(script_call)

          if self.check_result("transcript") == True:
            print("PASS")
            self.clean_up(test)
          else:
            print("FAILED")
            self.increment_num_failing_tests()


    def print_statistics(self):
      print("Results: " + str(self.get_num_failing_tests()) + " out of " + str(self.get_num_tests_run()) + " failed.\n")
