import sys
import os
import argparse
import re
from glob import glob


class CoverageFileReader(object):

    def __init__(self, filename):
        self.filename = filename
        self.content = None
        self.cp = None

    def read(self) -> bool:
        try:
            with open(self.filename, mode='r') as read_file:
                self.content = [file_line.strip() for file_line in read_file.readlines()]
        except OSError:
            print('Unable to open file: %s' % (self.filename))
            return False

        # Check file header
        if self.content[0] == "--UVVM_COVERAGE_FILE--":
            self.build_db()
            return True
        else:
            return False

    def get_coverpoint(self):
        return self.cp

    def build_db(self):
        pointer = 1  # Skip file header
        db = self.content

        self.cp = CoverPoint()
        
        self.cp.set_name(db[pointer].lower())
        pointer += 1

        self.cp.set_scope(db[pointer])
        pointer += 1

        number_of_bins_crossed = int(db[pointer])
        self.cp.set_number_of_bins_crossed(number_of_bins_crossed)
        pointer += 1

        self.cp.set_sampled_coverpoint(db[pointer])
        pointer += 1

        number_of_tc_accumulated = int(db[pointer])
        self.cp.set_number_of_tc_accumulated(number_of_tc_accumulated)
        pointer += 1

        seeds = db[pointer].split()
        self.cp.set_randomization_seed(seeds[0], seeds[1])
        pointer += 1

        self.cp.set_illegal_bin_alert_level(db[pointer])
        pointer += 1

        self.cp.set_bin_overlap_alert_level(db[pointer])
        pointer += 1

        self.cp.set_number_of_valid_bins(db[pointer])
        pointer += 1

        self.cp.set_number_of_covered_bins(db[pointer])
        pointer += 1

        self.cp.set_total_bin_min_hits(db[pointer])
        pointer += 1

        self.cp.set_total_bin_hits(db[pointer])
        pointer += 1

        self.cp.set_total_coverage_bin_hits(db[pointer])
        pointer += 1

        self.cp.set_total_goal_bin_hits(db[pointer])
        pointer += 1

        self.cp.set_covpt_coverage_weight(db[pointer])
        pointer += 1

        self.cp.set_bins_coverage_goal(db[pointer])
        pointer += 1

        self.cp.set_hits_coverage_goal(db[pointer])
        pointer += 1

        self.cp.set_covpts_coverage_goal(db[pointer])
        pointer += 1

        bin_idx = int(db[pointer])
        self.cp.set_bin_idx(bin_idx)
        pointer += 1

        if bin_idx > 0:
            for idx in range(0, bin_idx):
                bin = Bin()
                name = db[pointer]
                pointer += 1
                bin.set_name(name)

                bin_data = db[pointer].split()
                pointer += 1
                bin.set_hits(bin_data[0])
                bin.set_min_hits(bin_data[1])
                bin.set_rand_weight(bin_data[2])

                if number_of_bins_crossed > 0:
                    for sub_idx in range(0, number_of_bins_crossed):
                        cross = Cross()
                        cross_data = db[pointer]
                        pointer += 1

                        cross.set_bin_type(cross_data[0])
                        cross.set_num_values(cross_data[1])
                        cross.set_values(cross_data[2:])

                        bin.add_cross(cross)
                self.cp.add_bin(bin)

        invalid_bin_idx = int(db[pointer])
        self.cp.set_invalid_bin_idx(invalid_bin_idx)
        pointer += 1

        if bin_idx > 0:
        # if invalid_bin_idx > 0:
            for idx in range(0, invalid_bin_idx):
                invalid_bin = InvalidBin()
                name = db[pointer]
                pointer += 1
                invalid_bin.set_name(name)

                invalid_bin_data = db[pointer].split()
                pointer += 1
                invalid_bin.set_hits(invalid_bin_data[0])
                invalid_bin.set_min_hits(invalid_bin_data[1])
                invalid_bin.set_rand_weight(invalid_bin_data[2])

                if number_of_bins_crossed > 0:
                    for sub_idx in range(0, number_of_bins_crossed):
                        cross = Cross()
                        cross_data = db[pointer]
                        pointer += 1

                        cross.set_bin_type(cross_data[0])
                        cross.set_num_values(cross_data[1])
                        cross.set_values(cross_data[2:])

                        invalid_bin.add_cross(cross)
                self.cp.add_invalid_bin(invalid_bin)


class CoverPoint(object):

    def __init__(self):
        self.name = None
        self.scope = None
        self.number_of_bins_crossed = 0
        self.sampled_coverpoint = False
        self.number_of_tc_accumulated = 0
        self.randomization_seed_1 = 0
        self.randomization_seed_2 = 0
        self.illegal_bin_alert_level = None
        self.bin_overlap_alert_level = None
        self.number_of_valid_bins = 0
        self.number_of_covered_bins = 0
        self.total_bin_min_hits = 0
        self.total_bin_hits = 0
        self.total_coverage_bin_hits = 0
        self.total_goal_bin_hits = 0
        self.covpt_coverage_weight = 0
        self.bins_coverage_goal = 0
        self.hits_coverage_goal = 0
        self.covpts_coverage_goal = 0
        self.bin_idx = 0
        self.bins = []
        self.invalid_bin_idx = 0
        self.invalid_bins = []

    def set_name(self, name):
        self.name = name

    def get_name(self):
        return self.name

    def set_scope(self, scope):
        self.scope = scope

    def get_scope(self) -> str:
        return self.scope

    def set_number_of_bins_crossed(self, number_of_bins_crossed):
        self.number_of_bins_crossed = int(number_of_bins_crossed)

    def get_number_of_bins_crossed(self) -> int:
        return self.number_of_bins_crossed

    def set_sampled_coverpoint(self, sampled_coverpoint):
        self.sampled_coverpoint = sampled_coverpoint

    def get_sampled_coverpoint(self):
        return self.sampled_coverpoint

    def set_number_of_tc_accumulated(self, number_of_tc_accumulated):
        self.number_of_tc_accumulated = int(number_of_tc_accumulated)

    def get_number_of_tc_accumulated(self) -> int:
        return self.number_of_tc_accumulated

    def set_randomization_seed(self, seed1, seed2):
        self.randomization_seed_1 = seed1
        self.randomization_seed_2 = seed2

    def get_randomization_seed(self):
        return (self.randomization_seed_1, self.randomization_seed_2)

    def set_illegal_bin_alert_level(self, alert_level):
        self.illegal_bin_alert_level = alert_level

    def get_illegal_bin_alert_level(self):
        return self.illegal_bin_alert_level

    def set_bin_overlap_alert_level(self, alert_level):
        self.bin_overlap_alert_level = alert_level

    def get_bin_overlap_alert_level(self):
        return self.bin_overlap_alert_level

    def set_number_of_valid_bins(self, numb):
        self.number_of_valid_bins = numb

    def get_number_of_valid_bins(self):
        return self.number_of_valid_bins

    def set_number_of_covered_bins(self, numb):
        self.number_of_covered_bins = numb

    def get_number_of_covered_bins(self):
        return self.number_of_covered_bins

    def set_total_bin_min_hits(self, numb):
        self.total_bin_min_hits = numb

    def get_total_bin_min_hits(self):
        return self.total_bin_min_hits

    def set_total_bin_hits(self, numb):
        self.total_bin_hits = numb

    def get_total_bin_hits(self):
        return self.total_bin_hits

    def set_total_coverage_bin_hits(self, numb):
        self.total_coverage_bin_hits = numb

    def get_total_coverage_bin_hits(self):
        return self.total_coverage_bin_hits

    def set_total_goal_bin_hits(self, numb):
        self.total_goal_bin_hits = numb

    def get_total_goal_bin_hits(self):
        return self.total_goal_bin_hits

    def set_covpt_coverage_weight(self, numb):
        self.covpt_coverage_weight = numb

    def get_covpt_coverage_weight(self):
        return self.covpt_coverage_weight

    def set_bins_coverage_goal(self, numb):
        self.bins_coverage_goal = numb

    def get_bins_coverage_goal(self):
        return self.bins_coverage_goal

    def set_hits_coverage_goal(self, numb):
        self.hits_coverage_goal = numb

    def get_hits_coverage_goal(self):
        return self.hits_coverage_goal

    def set_covpts_coverage_goal(self, numb):
        self.covpts_coverage_goal = numb

    def get_covpts_coverage_goal(self):
        return self.covpts_coverage_goal

    def set_bin_idx(self, numb):
        self.bin_idx = numb

    def get_bin_idx(self):
        return self.bin_idx

    def set_bins(self, bins):
        self.bins = bins

    def add_bin(self, bin):
        self.bins.append(bin)

    def get_bins(self):
        return self.bins

    def set_invalid_bin_idx(self, idx):
        self.invalid_bin_idx = idx

    def get_invalid_bin_idx(self):
        return self.invalid_bin_idx

    def set_invalid_bins(self, bins):
        self.invalid_bins = bins

    def add_invalid_bin(self, bin):
        self.invalid_bins.append(bin)

    def get_invalid_bins(self):
        return self.invalid_bins


class Bin(object):

    def __init__(self):
        self.name = None
        self.hits = 0
        self.min_hits = 0
        self.rand_weight = 0
        self.cross = []

    def set_name(self, name):
        self.name = name

    def get_name(self):
        return self.name

    def set_hits(self, numb):
        self.hits = numb

    def get_hits(self):
        return self.hits

    def set_min_hits(self, numb):
        self.min_hits = numb

    def get_min_hits(self):
        return self.min_hits

    def set_rand_weight(self, numb):
        self.rand_weight = numb

    def get_rand_weight(self):
        return self.rand_weight

    def add_cross(self, cross):
        self.cross.append(cross)

    def get_cross(self):
        return self.cross


class InvalidBin(Bin):

    def __init__(self):
        self.name = None
        self.hits = 0
        self.min_hits = 0
        self.rand_weight = 0
        self.cross = []


class Cross(object):

    def __init__(self):
        self.bin_type = None
        self.num_values = 0
        self.values = []

    def set_bin_type(self, bin_type):
        self.bin_type = bin_type

    def get_bin_type(self):
        return self.bin_type

    def set_num_values(self, numb):
        self.num_values = numb

    def get_num_values(self):
        return self.num_values

    def set_values(self, values):
        self.values = values

    def add_value(self, value):
        self.values.append(value)

    def get_values(self):
        return self.values


class CoverageMerger(object):

    def __init__(self):
        self.cov_dir = './hdlunit/test'
        self.cov_file = '*.txt'
        self.recursive = False
        self.cov_file_reader_list = []
        self._info()
        self._args()
        self.file_finder()

    def file_finder(self):
        if self.recursive is True:
            filename = os.path.join(self.cov_dir, '**', self.cov_file)
        else:
            filename = os.path.join(self.cov_dir, self.cov_file)

        cov_file_dir = os.path.normpath(filename)
        cov_file_dir = os.path.realpath(cov_file_dir)

        files_list = glob(cov_file_dir, recursive = True)

        for item in files_list:
            cfr = CoverageFileReader(item)
            if cfr.read() == True:
                self.cov_file_reader_list.append(cfr)

    def merge(self):
        print('Searching for %s in %s' % (self.cov_file, self.cov_dir))

        for cp_file in self.cov_file_reader_list:
            cp = cp_file.get_coverpoint()
            print('\nCoverpoint: %s' % (cp.get_name()))

            for bin in cp.get_bins():
                print('Bin: %s' % (bin.get_name()))

            for invalid_bin in cp.get_invalid_bins():
                print('Invalid bin: %s' % (invalid_bin.get_name()))

    def _info(self):
        print('** Running UVVM Coverage Database Merger **')

    def _args(self):
        arg_parser = argparse.ArgumentParser(description='UVVM Coverage Database Merger')
        arg_parser.add_argument('-d', '--dir', action='store', type=str, nargs=1, help='search directory. Default = ./hdlunit/test')
        arg_parser.add_argument('-f', '--file', action='store', type=str, nargs=1, help='coverage database file ending. Default = .txt')
        arg_parser.add_argument('-r', '--recursive', action='store_true', help='recursive directory file search. Default = no recursive search')

        args = arg_parser.parse_args(sys.argv[1:])

        if args.dir:
            self.cov_dir = args.dir[0]
        if args.file:
            self.cov_file = args.file[0]
        if args.recursive:
            self.recursive = True


if __name__ == '__main__':
    cm = CoverageMerger()
    cm.merge()