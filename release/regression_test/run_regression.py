import sys, subprocess, os


def cd_to_module(module):
  sim_path = '../../' + module.lower() + '/sim'

  if module == None or len(module) == 0:
    return
  else:
    if not os.path.exists(sim_path):
        os.mkdir(sim_path)

    os.chdir(sim_path)


def get_module_list():
  modules = []
  for line in open("module_list.txt", 'r'):
    if not line[0].strip() == "#":
      modules.append(line.lower().rstrip('\n'))

  return modules


def simulate_module(module):
  print("\nSimulating module: " + module)
  if module == None or len(module) == 0:
    return 0

  try:
    print(' '.join(sys.argv[1:]))
    subprocess.check_call([sys.executable, "../../" + str(module) + "/internal_script/run.py", ' '.join(sys.argv[1:])])
    return 0
  except subprocess.CalledProcessError as e:
    print("Number of failing tests: " + str(e.returncode))
    return int(e.returncode)


def present_results(num_failing_tests):
  print("---------------------------------------------")
  if num_failing_tests > 0:
    print("Regression test FAILED with a total of " + str(num_failing_tests) + " failing tests.")
  else:
    print("Regression test SUCCEEDED with a total of 0 failing tests.")



def main():
  modules = get_module_list()
  num_failing_tests = 0

  for module in modules:
    cd_to_module(module)
    simulate_module(module)

  present_results(num_failing_tests)


if __name__ == "__main__":
  main()