import sys
import os
import argparse
import re
from glob import glob

t_cov_bin_type = {0: "VAL",
                  1: "VAL_IGNORE",
                  2: "VAL_ILLEGAL",
                  3: "RAN",
                  4: "RAN_IGNORE",
                  5: "RAN_ILLEGAL",
                  6: "TRN",
                  7: "TRN_IGNORE",
                  8: "TRN_ILLEGAL"}


class bcolors:
    OKGREEN = '\033[32m'
    WARNING = '\033[33m'
    ENDC = '\033[37;40m'


class CoverageFileReader(object):

    def __init__(self, filename):
        self.filename = filename
        self.content = None
        self.covpt = None

    def read(self) -> bool:
        try:
            with open(self.filename, mode='r') as read_file:
                self.content = [file_line.strip() for file_line in read_file.readlines()]
        except OSError:
            print('Unable to open file: {}'.format(self.filename))
            return False

        # Check file header
        if len(self.content) != 0 and self.content[0] == "--UVVM_FUNCTIONAL_COVERAGE_FILE--":
            self.build_db()
            return True
        else:
            return False

    def get_coverpoint(self):
        return self.covpt

    def build_db(self):
        pointer = 1  # Skip file header
        db = self.content

        self.covpt = CoverPoint()
        
        self.covpt.set_name(db[pointer])
        pointer += 1

        self.covpt.set_scope(db[pointer])
        pointer += 1

        number_of_bins_crossed = int(db[pointer])
        self.covpt.set_number_of_bins_crossed(number_of_bins_crossed)
        pointer += 1

        self.covpt.set_sampled_coverpoint(db[pointer])
        pointer += 1

        self.covpt.set_number_of_tc_accumulated(db[pointer])
        pointer += 1

        seeds = db[pointer].split()
        self.covpt.set_randomization_seed(seeds[0], seeds[1])
        pointer += 1

        self.covpt.set_illegal_bin_alert_level(db[pointer])
        pointer += 1

        self.covpt.set_bin_overlap_alert_level(db[pointer])
        pointer += 1

        self.covpt.set_number_of_valid_bins(db[pointer])
        pointer += 1

        self.covpt.set_number_of_covered_bins(db[pointer])
        pointer += 1

        self.covpt.set_total_bin_min_hits(db[pointer])
        pointer += 1

        self.covpt.set_total_bin_hits(db[pointer])
        pointer += 1

        self.covpt.set_total_coverage_bin_hits(db[pointer])
        pointer += 1

        self.covpt.set_total_goal_bin_hits(db[pointer])
        pointer += 1

        self.covpt.set_covpt_coverage_weight(db[pointer])
        pointer += 1

        self.covpt.set_bins_coverage_goal(db[pointer])
        pointer += 1

        self.covpt.set_hits_coverage_goal(db[pointer])
        pointer += 1

        self.covpt.set_covpts_coverage_goal(db[pointer])
        pointer += 1

        bin_idx = int(db[pointer])
        self.covpt.set_bin_idx(bin_idx)
        pointer += 1

        if bin_idx > 0:
            for idx in range(0, bin_idx):
                bin = Bin()
                bin.set_name(db[pointer])
                pointer += 1

                bin_data = db[pointer].split()
                pointer += 1
                bin.set_hits(bin_data[0])
                bin.set_min_hits(bin_data[1])
                bin.set_rand_weight(bin_data[2])

                if number_of_bins_crossed > 0:
                    for sub_idx in range(0, number_of_bins_crossed):
                        cross_bin = CrossBin()
                        cross_bin_data = db[pointer].split()
                        pointer += 1
                        cross_bin.set_bin_type(cross_bin_data[0])
                        cross_bin.set_num_values(cross_bin_data[1])
                        cross_bin.set_values(cross_bin_data[2:])

                        bin.add_cross_bin(cross_bin)
                self.covpt.add_bin(bin)

        invalid_bin_idx = int(db[pointer])
        self.covpt.set_invalid_bin_idx(invalid_bin_idx)
        pointer += 1

        if invalid_bin_idx > 0:
            for idx in range(0, invalid_bin_idx):
                invalid_bin = Bin()
                invalid_bin.set_name(db[pointer])
                pointer += 1

                invalid_bin_data = db[pointer].split()
                pointer += 1
                invalid_bin.set_hits(invalid_bin_data[0])
                invalid_bin.set_min_hits(invalid_bin_data[1])
                invalid_bin.set_rand_weight(invalid_bin_data[2])

                if number_of_bins_crossed > 0:
                    for sub_idx in range(0, number_of_bins_crossed):
                        cross_bin = CrossBin()
                        cross_bin_data = db[pointer].split()
                        pointer += 1
                        cross_bin.set_bin_type(cross_bin_data[0])
                        cross_bin.set_num_values(cross_bin_data[1])
                        cross_bin.set_values(cross_bin_data[2:])

                        invalid_bin.add_cross_bin(cross_bin)
                self.covpt.add_invalid_bin(invalid_bin)


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
        self.bins_mismatch = False
        self.report_width = 130
        self.report_bin_width = 40

    def set_name(self, name):
        self.name = name

    def get_name(self) -> str:
        return self.name

    def set_scope(self, scope):
        self.scope = scope

    def get_scope(self) -> str:
        return self.scope

    def set_number_of_bins_crossed(self, num):
        self.number_of_bins_crossed = int(num)

    def get_number_of_bins_crossed(self) -> int:
        return self.number_of_bins_crossed

    def set_sampled_coverpoint(self, sampled_coverpoint):
        self.sampled_coverpoint = sampled_coverpoint

    def get_sampled_coverpoint(self) -> bool:
        return self.sampled_coverpoint

    def set_number_of_tc_accumulated(self, num):
        self.number_of_tc_accumulated = int(num)

    def increment_number_of_tc_accumulated(self, num):
        self.number_of_tc_accumulated += int(num)

    def get_number_of_tc_accumulated(self) -> int:
        return self.number_of_tc_accumulated

    def set_randomization_seed(self, seed1, seed2):
        self.randomization_seed_1 = seed1
        self.randomization_seed_2 = seed2

    def get_randomization_seed(self):
        return (self.randomization_seed_1, self.randomization_seed_2)

    def set_illegal_bin_alert_level(self, alert_level):
        self.illegal_bin_alert_level = alert_level

    def get_illegal_bin_alert_level(self) -> str:
        return self.illegal_bin_alert_level

    def set_bin_overlap_alert_level(self, alert_level):
        self.bin_overlap_alert_level = alert_level

    def get_bin_overlap_alert_level(self) -> str:
        return self.bin_overlap_alert_level

    def set_number_of_valid_bins(self, num):
        self.number_of_valid_bins = int(num)

    def get_number_of_valid_bins(self) -> int:
        return self.number_of_valid_bins

    def set_number_of_covered_bins(self, num):
        self.number_of_covered_bins = int(num)

    def get_number_of_covered_bins(self) -> int:
        return self.number_of_covered_bins

    def set_total_bin_min_hits(self, hits):
        self.total_bin_min_hits = int(hits)

    def get_total_bin_min_hits(self) -> int:
        return self.total_bin_min_hits

    def set_total_bin_hits(self, hits):
        self.total_bin_hits = int(hits)

    def increment_total_bin_hits(self, hits):
        self.total_bin_hits += int(hits)

    def get_total_bin_hits(self) -> int:
        return self.total_bin_hits

    def set_total_coverage_bin_hits(self, hits):
        self.total_coverage_bin_hits = int(hits)

    def get_total_coverage_bin_hits(self) -> int:
        return self.total_coverage_bin_hits

    def set_total_goal_bin_hits(self, hits):
        self.total_goal_bin_hits = int(hits)

    def get_total_goal_bin_hits(self) -> int:
        return self.total_goal_bin_hits

    def set_covpt_coverage_weight(self, weight):
        self.covpt_coverage_weight = int(weight)

    def get_covpt_coverage_weight(self) -> int:
        return self.covpt_coverage_weight

    def set_bins_coverage_goal(self, goal):
        self.bins_coverage_goal = int(goal)

    def get_bins_coverage_goal(self) -> int:
        return self.bins_coverage_goal

    def set_hits_coverage_goal(self, goal):
        self.hits_coverage_goal = int(goal)

    def get_hits_coverage_goal(self) -> int:
        return self.hits_coverage_goal

    def set_covpts_coverage_goal(self, goal):
        self.covpts_coverage_goal = int(goal)

    def get_covpts_coverage_goal(self) -> int:
        return self.covpts_coverage_goal

    def set_bin_idx(self, idx):
        self.bin_idx = int(idx)

    def get_bin_idx(self) -> int:
        return self.bin_idx

    def set_bins(self, bins):
        self.bins = bins

    def add_bin(self, bin):
        self.bins.append(bin)

    def get_bins(self):
        return self.bins

    def set_invalid_bin_idx(self, idx):
        self.invalid_bin_idx = int(idx)

    def get_invalid_bin_idx(self) -> int:
        return self.invalid_bin_idx

    def set_invalid_bins(self, bins):
        self.invalid_bins = bins

    def add_invalid_bin(self, bin):
        self.invalid_bins.append(bin)

    def get_invalid_bins(self):
        return self.invalid_bins

    def set_bins_mismatch(self, mismatch):
        self.bins_mismatch = mismatch

    def get_bins_mismatch(self) -> bool:
        return self.bins_mismatch

    def get_bins_coverage(self, cov_representation) -> float:
        coverage = 0.0
        if self.number_of_valid_bins > 0:
            coverage = self.number_of_covered_bins * 100 / self.number_of_valid_bins
        if cov_representation == "GOAL_CAPPED" or cov_representation == "GOAL_UNCAPPED":
            coverage *= 100 / self.bins_coverage_goal
        if cov_representation == "GOAL_CAPPED" and coverage > 100.0:
            coverage = 100.0
        return coverage

    def get_hits_coverage(self, cov_representation) -> float:
        coverage = 0.0
        tot_goal_bin_min_hits = self.total_bin_min_hits * self.hits_coverage_goal / 100
        if cov_representation == "GOAL_CAPPED":
            if tot_goal_bin_min_hits > 0.0:
                coverage = self.total_goal_bin_hits * 100 / tot_goal_bin_min_hits
            if coverage > 100.0:
                coverage = 100.0
        elif cov_representation == "GOAL_UNCAPPED":
            if tot_goal_bin_min_hits > 0.0:
                coverage = self.total_bin_hits * 100 / tot_goal_bin_min_hits
        else: # NO_GOAL
            if self.total_bin_min_hits > 0:
                coverage = self.total_coverage_bin_hits * 100 / self.total_bin_min_hits
        return coverage

    def print_report(self, file_name, verbosity):
        if verbosity == 'VERBOSE':
            title = 'COVERAGE SUMMARY REPORT (VERBOSE)'
        elif verbosity == 'NON_VERBOSE':
            title = 'COVERAGE SUMMARY REPORT (NON VERBOSE)'
        elif verbosity == 'HOLES':
            title = 'COVERAGE HOLES REPORT'

        txt = []
        txt.append('{:=<{width}}'.format('=', width=self.report_width))
        txt.append('*** {} ***'.format(title))
        txt.append('{:=<{width}}'.format('=', width=self.report_width))
        txt.append('Coverpoint:              {}    (accumulated over {} testcases)'.format(self.name, self.number_of_tc_accumulated))

        if self.bins_coverage_goal != 100 or self.hits_coverage_goal != 100:
            bins_goal = '{}'.format(self.bins_coverage_goal) + '%,'
            hits_goal = '{}'.format(self.hits_coverage_goal) + '%'
            txt.append('Goal:                    Bins: {:<10} Hits: {:<10}'.format(bins_goal, hits_goal))
            bins_cov = '{:.2f}'.format(self.get_bins_coverage("GOAL_CAPPED")) + '%,'
            hits_cov = '{:.2f}'.format(self.get_hits_coverage("GOAL_CAPPED")) + '%'
            txt.append('% of Goal:               Bins: {:<10} Hits: {:<10}'.format(bins_cov, hits_cov))
            bins_cov = '{:.2f}'.format(self.get_bins_coverage("GOAL_UNCAPPED")) + '%,'
            hits_cov = '{:.2f}'.format(self.get_hits_coverage("GOAL_UNCAPPED")) + '%'
            txt.append('% of Goal (uncapped):    Bins: {:<10} Hits: {:<10}'.format(bins_cov, hits_cov))
        bins_cov = '{:.2f}'.format(self.get_bins_coverage("NO_GOAL")) + '%,'
        hits_cov = '{:.2f}'.format(self.get_hits_coverage("NO_GOAL")) + '%'
        txt.append('Coverage (for goal 100): Bins: {:<10} Hits: {:<10}'.format(bins_cov, hits_cov))
        txt.append('{:-<{width}}'.format('-', width=self.report_width))

        txt.append('{:^{bin_col}} {:^15} {:^15} {:^15} {:^20} {:^15}'.format('BINS','HITS','MIN HITS','HIT COVERAGE','NAME','ILLEGAL/IGNORE',bin_col=self.report_bin_width))
        for invalid_bin in self.invalid_bins:
            if invalid_bin.is_bin_illegal() is True and (verbosity == 'VERBOSE' or (verbosity == 'NON_VERBOSE' and invalid_bin.get_hits() > 0)):
                txt.append('{:^{bin_col}.{bin_col}} {:^15} {:^15} {:^15} {:^20.20} {:^15}'.format(invalid_bin.print_bin_info(self.report_bin_width), invalid_bin.get_hits(), 'N/A', 'N/A', invalid_bin.get_name(), 'ILLEGAL', bin_col=self.report_bin_width))
        for invalid_bin in self.invalid_bins:
            if invalid_bin.is_bin_ignore() is True and verbosity == 'VERBOSE':
                txt.append('{:^{bin_col}.{bin_col}} {:^15} {:^15} {:^15} {:^20.20} {:^15}'.format(invalid_bin.print_bin_info(self.report_bin_width), invalid_bin.get_hits(), 'N/A', 'N/A', invalid_bin.get_name(), 'IGNORE', bin_col=self.report_bin_width))
        for bin in self.bins:
            if verbosity == 'VERBOSE' or verbosity == 'NON_VERBOSE' or (verbosity == 'HOLES' and bin.get_hits() < bin.get_total_min_hits(self.hits_coverage_goal)):
                hit_cov = '{:.2f}'.format(bin.get_bin_coverage()) + '%'
                txt.append('{:^{bin_col}.{bin_col}} {:^15} {:^15} {:^15} {:^20.20} {:^15}'.format(bin.print_bin_info(self.report_bin_width), bin.get_hits(), bin.get_min_hits(), hit_cov, bin.get_name(), '-', bin_col=self.report_bin_width))
        txt.append('{:-<{width}}'.format('-', width=self.report_width))

        for invalid_bin in self.invalid_bins:
            if invalid_bin.is_bin_illegal() is True and (verbosity == 'VERBOSE' or (verbosity == 'NON_VERBOSE' and invalid_bin.get_hits() > 0)):
                if invalid_bin.print_bin_info(self.report_bin_width) == invalid_bin.get_name():
                    txt.append('{}: {}'.format(invalid_bin.get_name(), invalid_bin.print_bin_info()))
        for invalid_bin in self.invalid_bins:
            if invalid_bin.is_bin_ignore() is True and verbosity == 'VERBOSE':
                if invalid_bin.print_bin_info(self.report_bin_width) == invalid_bin.get_name():
                    txt.append('{}: {}'.format(invalid_bin.get_name(), invalid_bin.print_bin_info()))
        for bin in self.bins:
            if verbosity == 'VERBOSE' or verbosity == 'NON_VERBOSE' or (verbosity == 'HOLES' and bin.get_hits() < bin.get_total_min_hits(self.hits_coverage_goal)):
                if bin.print_bin_info(self.report_bin_width) == bin.get_name():
                    txt.append('{}: {}'.format(bin.get_name(), bin.print_bin_info()))
        txt.append('{:=<{width}}'.format('=', width=self.report_width))

        with open(file_name, mode='a') as output_file:
            for line in txt:
                output_file.write(line + '\n') # Print to file
                print(line)                    # Print to terminal


class Bin(object):

    def __init__(self):
        self.name = None
        self.hits = 0
        self.min_hits = 0
        self.rand_weight = 0
        self.cross_bins = []

    def set_name(self, name):
        self.name = name

    def get_name(self) -> str:
        return self.name

    def set_hits(self, hits):
        self.hits = int(hits)

    def increment_hits(self, hits):
        self.hits += int(hits)

    def get_hits(self) -> int:
        return self.hits

    def set_min_hits(self, hits):
        self.min_hits = int(hits)

    def get_min_hits(self) -> int:
        return self.min_hits

    def get_total_min_hits(self, hits_coverage_goal) -> int:
        return int(round(self.min_hits * hits_coverage_goal / 100, 0))

    def set_rand_weight(self, weight):
        self.rand_weight = int(weight)

    def get_rand_weight(self) -> int:
        return self.rand_weight

    def add_cross_bin(self, cross_bin):
        self.cross_bins.append(cross_bin)

    def get_cross_bins(self):
        return self.cross_bins

    def compare_cross_bins(self, exp_cross_bins) -> bool:
        if len(self.cross_bins) != len(exp_cross_bins):
            return False
        else:
            for idx, cross_bin in enumerate(self.cross_bins):
                if cross_bin.get_bin_type() != exp_cross_bins[idx].get_bin_type() or cross_bin.get_num_values() != exp_cross_bins[idx].get_num_values() or cross_bin.get_values() != exp_cross_bins[idx].get_values():
                    return False
        return True

    def is_bin_illegal(self) -> bool:
        for cross_bin in self.cross_bins:
            bin_type = cross_bin.get_bin_type()
            if bin_type == "VAL_ILLEGAL" or bin_type == "RAN_ILLEGAL" or bin_type == "TRN_ILLEGAL":
                return True
        else:
            return False

    def is_bin_ignore(self) -> bool:
        for cross_bin in self.cross_bins:
            bin_type = cross_bin.get_bin_type()
            if bin_type == "VAL_IGNORE" or bin_type == "RAN_IGNORE" or bin_type == "TRN_IGNORE":
                return True
        else:
            return False

    def get_bin_coverage(self) -> float:
        if self.hits < self.min_hits:
            return self.hits * 100 / self.min_hits;
        else:
            return 100.0

    def print_bin_info(self, max_width=-1) -> str:
        txt = ''
        for cross_idx, cross_bin in enumerate(self.cross_bins):
            bin_type = cross_bin.get_bin_type()
            values = cross_bin.get_values()
            if bin_type == "VAL" or bin_type == "VAL_IGNORE" or bin_type == "VAL_ILLEGAL":
                txt += '('
                for idx, val in enumerate(values):
                    txt += val
                    if idx < len(values)-1: txt += ','
                txt += ')'
            elif bin_type == "RAN" or bin_type == "RAN_IGNORE" or bin_type == "RAN_ILLEGAL":
                txt += '(' + values[0] + ' to ' + values[1] + ')'
            elif bin_type == "TRN" or bin_type == "TRN_IGNORE" or bin_type == "TRN_ILLEGAL":
                txt += '('
                for idx, val in enumerate(values):
                    txt += val
                    if idx < len(values)-1: txt += '->'
                txt += ')'
            if cross_idx < len(self.cross_bins)-1: txt += 'x'

        if max_width != -1 and len(txt) > max_width:
            return self.name
        else:
            return txt


class CrossBin(object):

    def __init__(self):
        self.bin_type = None
        self.num_values = 0
        self.values = []

    def set_bin_type(self, bin_type):
        self.bin_type = t_cov_bin_type[int(bin_type)]

    def get_bin_type(self) -> str:
        return self.bin_type

    def set_num_values(self, num):
        self.num_values = int(num)

    def get_num_values(self) -> int:
        return self.num_values

    def set_values(self, values):
        self.values = values

    def add_value(self, value):
        self.values.append(value)

    def get_values(self):
        return self.values


class CoverageMerger(object):

    def __init__(self):
        self.cov_dir = '.'
        self.cov_file = '*.txt'
        self.output_file = 'func_cov_accumulated.txt'
        self.recursive = False
        self.ignore_mismatch = False
        self.verbose = True
        self.holes = False
        self.cov_file_reader_list = []
        self.merged_covpt_list = []
        self.report_width = 150
        self._info()
        self._args()
        self._file_finder()

    def _info(self):
        print('** Running UVVM Coverage Database Merger **')

    def _args(self):
        arg_parser = argparse.ArgumentParser(description='UVVM Coverage Database Merger')
        arg_parser.add_argument('-d', '--dir', action='store', type=str, nargs=1, help='search directory. Default = current directory')
        arg_parser.add_argument('-f', '--file', action='store', type=str, nargs=1, help='coverage database file name/extension. Default = .txt')
        arg_parser.add_argument('-o', '--output', action='store', type=str, nargs=1, help='coverage database output file. Default = func_cov_accumulated.txt')
        arg_parser.add_argument('-r', '--recursive', action='store_true', help='recursive directory file search')
        arg_parser.add_argument('-im', '--ignore_mismatch', action='store_true', help='do not report coverpoints with mismatching bins')
        arg_parser.add_argument('-nv', '--non_verbose', action='store_true', help='print non_verbose report. Default = verbose')
        arg_parser.add_argument('-hl', '--holes', action='store_true', help='print coverage holes report. Default = verbose')

        args = arg_parser.parse_args(sys.argv[1:])

        if args.dir:
            self.cov_dir = args.dir[0]
        if args.file:
            self.cov_file = args.file[0]
        if args.output:
            self.output_file = args.output[0]
        if args.recursive:
            self.recursive = True
        if args.ignore_mismatch:
            self.ignore_mismatch = True
        if args.non_verbose:
            self.verbose = False
        if args.holes:
            self.verbose = False
            self.holes = True

    def _file_finder(self):
        if self.recursive is True:
            print('Searching for {} in {} using recursive search'.format(self.cov_file, self.cov_dir))
        else:
            print('Searching for {} in {}'.format(self.cov_file, self.cov_dir))

        if self.recursive is True:
            filename = os.path.join(self.cov_dir, '**', self.cov_file)
        else:
            filename = os.path.join(self.cov_dir, self.cov_file)

        cov_file_dir = os.path.normpath(filename)
        cov_file_dir = os.path.realpath(cov_file_dir)

        files_list = sorted(glob(cov_file_dir, recursive = True))

        for item in files_list:
            cfr = CoverageFileReader(item)
            if cfr.read() is True:
                self.cov_file_reader_list.append(cfr)

        if os.path.exists(self.output_file):
            os.remove(self.output_file)

    def _get_total_bins_coverage(self) -> float:
        tot_covered_bins = 0
        tot_valid_bins = 0
        for covpt in self.merged_covpt_list:
            tot_covered_bins += covpt.get_number_of_covered_bins() * covpt.get_covpt_coverage_weight()
            tot_valid_bins   += covpt.get_number_of_valid_bins() * covpt.get_covpt_coverage_weight()
        if tot_valid_bins > 0:
            return tot_covered_bins * 100 / tot_valid_bins
        else:
            return 0.0

    def _get_total_hits_coverage(self) -> float:
        tot_bin_hits = 0
        tot_bin_min_hits = 0
        for covpt in self.merged_covpt_list:
            tot_bin_hits     += covpt.get_total_coverage_bin_hits() * covpt.get_covpt_coverage_weight()
            tot_bin_min_hits += covpt.get_total_bin_min_hits() * covpt.get_covpt_coverage_weight()
        if tot_bin_min_hits > 0:
            return tot_bin_hits * 100 / tot_bin_min_hits
        else:
            return 0.0

    def _get_total_covpts_coverage(self, cov_representation) -> float:
        tot_covered_covpts = 0
        tot_covpts = 0
        coverage = 0.0
        for covpt in self.merged_covpt_list:
            if covpt.get_total_coverage_bin_hits() >= covpt.get_total_bin_min_hits():
                tot_covered_covpts += covpt.get_covpt_coverage_weight()
            tot_covpts += covpt.get_covpt_coverage_weight()
        if tot_covpts > 0:
            coverage = tot_covered_covpts * 100 / tot_covpts
        if cov_representation == "GOAL_CAPPED" or cov_representation == "GOAL_UNCAPPED":
            coverage = coverage * 100 / covpt.get_covpts_coverage_goal()
        if cov_representation == "GOAL_CAPPED" and coverage > 100.0:
            coverage = 100.0
        return coverage

    def _print_overall_report(self, verbosity):
        if verbosity == 'VERBOSE':
            title = 'OVERALL COVERAGE REPORT (VERBOSE)'
        elif verbosity == 'NON_VERBOSE':
            title = 'OVERALL COVERAGE REPORT (NON VERBOSE)'
        elif verbosity == 'HOLES':
            title = 'OVERALL HOLES REPORT'

        txt = []
        txt.append('{:=<{width}}'.format('=', width=self.report_width))
        txt.append('*** {} ***'.format(title))
        txt.append('{:=<{width}}'.format('=', width=self.report_width))

        if self.merged_covpt_list[0].get_covpts_coverage_goal() != 100:
            covpts_goal = '{}'.format(self.merged_covpt_list[0].get_covpts_coverage_goal()) + '%'
            txt.append('Goal:                    Covpts: {:<10}'.format(covpts_goal))
            covpts_cov = '{:.2f}'.format(self._get_total_covpts_coverage("GOAL_CAPPED")) + '%'
            txt.append('% of Goal:               Covpts: {:<10}'.format(covpts_cov))
            covpts_cov = '{:.2f}'.format(self._get_total_covpts_coverage("GOAL_UNCAPPED")) + '%'
            txt.append('% of Goal (uncapped):    Covpts: {:<10}'.format(covpts_cov))
        covpts_cov = '{:.2f}'.format(self._get_total_covpts_coverage("NO_GOAL")) + '%,'
        bins_cov = '{:.2f}'.format(self._get_total_bins_coverage()) + '%,'
        hits_cov = '{:.2f}'.format(self._get_total_hits_coverage()) + '%'
        txt.append('Coverage (for goal 100): Covpts: {:<10} Bins: {:<10} Hits: {:<10}'.format(covpts_cov, bins_cov, hits_cov))
        txt.append('{:=<{width}}'.format('=', width=self.report_width))

        if verbosity == 'VERBOSE' or verbosity == 'HOLES':
            txt.append('{:^20} {:^20} {:^20} {:^20} {:^20} {:^20} {:^20}'.format('COVERPOINT','COVERAGE WEIGHT','COVERED BINS','COVERAGE(BINS|HITS)','GOAL(BINS|HITS)','% OF GOAL(BINS|HITS)','NUM TESTCASES'))
            for covpt in self.merged_covpt_list:
                if verbosity != 'HOLES' or covpt.get_bins_coverage("GOAL_CAPPED") != 100.0 or covpt.get_hits_coverage("GOAL_CAPPED") != 100.0:
                    covered_bins = '{} / {}'.format(covpt.get_number_of_covered_bins(), covpt.get_number_of_valid_bins())
                    bins_cov = '{:.2f}'.format(covpt.get_bins_coverage("NO_GOAL")) + '%'
                    hits_cov = '{:.2f}'.format(covpt.get_hits_coverage("NO_GOAL")) + '%'
                    coverage = '{} | {}'.format(bins_cov, hits_cov)
                    bins_goal = '{}'.format(covpt.bins_coverage_goal) + '%'
                    hits_goal = '{}'.format(covpt.hits_coverage_goal) + '%'
                    goal = '{} | {}'.format(bins_goal, hits_goal)
                    bins_cov = '{:.2f}'.format(covpt.get_bins_coverage("GOAL_CAPPED")) + '%'
                    hits_cov = '{:.2f}'.format(covpt.get_hits_coverage("GOAL_CAPPED")) + '%'
                    coverage_w_goal = '{} | {}'.format(bins_cov, hits_cov)
                    txt.append('{:^20.20} {:^20} {:^20} {:^20} {:^20} {:^20} {:^20}'.format(covpt.get_name(), covpt.get_covpt_coverage_weight(), covered_bins, coverage, goal, coverage_w_goal, covpt.get_number_of_tc_accumulated()))
            txt.append('{:=<{width}}'.format('=', width=self.report_width))

        with open(self.output_file, mode='a') as output_file:
            for line in txt:
                output_file.write(line + '\n') # Print to file
                print(line)                    # Print to terminal

    def merge(self):
        if len(self.cov_file_reader_list) == 0:
            print('No valid database files were found')
            sys.exit(1)

        for cov_file in self.cov_file_reader_list:
            new_covpt = cov_file.get_coverpoint()
            merged = False
            # Compare the coverpoint loaded from a new file against the merged coverpoints list
            for merged_covpt in self.merged_covpt_list:
                # Coverpoints must match in: name & number_of_bins_crossed
                if merged_covpt.get_name().lower() == new_covpt.get_name().lower() and merged_covpt.get_number_of_bins_crossed() == new_covpt.get_number_of_bins_crossed():
                    # Overwrite coverpoint's configuration with latest loaded data
                    merged_covpt.set_covpt_coverage_weight(new_covpt.get_covpt_coverage_weight())
                    merged_covpt.set_bins_coverage_goal(new_covpt.get_bins_coverage_goal())
                    merged_covpt.set_hits_coverage_goal(new_covpt.get_hits_coverage_goal())
                    merged_covpt.set_covpts_coverage_goal(new_covpt.get_covpts_coverage_goal())

                    # Merge bins
                    new_bin_list = new_covpt.get_bins()
                    merged_bin_list = merged_covpt.get_bins()
                    if len(new_bin_list) != len(merged_bin_list):
                        merged_covpt.set_bins_mismatch(True)
                    for merged_bin in merged_bin_list:
                        for new_bin in new_bin_list[:]:
                            if merged_bin.compare_cross_bins(new_bin.get_cross_bins()) and merged_bin.get_min_hits() == new_bin.get_min_hits() and merged_bin.get_rand_weight() == new_bin.get_rand_weight():
                                merged_bin.set_name(new_bin.get_name())
                                merged_bin.increment_hits(new_bin.get_hits())
                                new_bin_list.remove(new_bin)
                                break
                    if len(new_bin_list) != 0:
                        merged_covpt.set_bins_mismatch(True)
                    # Add any extra bins not found in previous files
                    merged_bin_list.extend(new_bin_list)
                    merged_covpt.set_bins(merged_bin_list)

                    # Calculate new coverage counters after merging
                    num_valid_bins = merged_covpt.get_number_of_valid_bins() + len(new_bin_list)
                    total_bin_min_hits = merged_covpt.get_total_bin_min_hits()
                    for new_bin in new_bin_list:
                        total_bin_min_hits += new_bin.get_min_hits()
                    num_covered_bins = 0
                    total_coverage_bin_hits = 0
                    total_goal_bin_hits = 0
                    for merged_bin in merged_bin_list:
                        if merged_bin.get_hits() >= merged_bin.get_min_hits():
                            num_covered_bins += 1
                            total_coverage_bin_hits += merged_bin.get_min_hits()
                        else:
                            total_coverage_bin_hits += merged_bin.get_hits()
                        if merged_bin.get_hits() >= merged_bin.get_total_min_hits(merged_covpt.get_hits_coverage_goal()):
                            total_goal_bin_hits += merged_bin.get_total_min_hits(merged_covpt.get_hits_coverage_goal())
                        else:
                            total_goal_bin_hits += merged_bin.get_hits()

                    # Merge ignore and illegal bins
                    new_bin_list = new_covpt.get_invalid_bins()
                    merged_bin_list = merged_covpt.get_invalid_bins()
                    if len(new_bin_list) != len(merged_bin_list):
                        merged_covpt.set_bins_mismatch(True)
                    for merged_bin in merged_bin_list:
                        for new_bin in new_bin_list[:]:
                            if merged_bin.compare_cross_bins(new_bin.get_cross_bins()) and merged_bin.get_min_hits() == new_bin.get_min_hits() and merged_bin.get_rand_weight() == new_bin.get_rand_weight():
                                merged_bin.set_name(new_bin.get_name())
                                merged_bin.increment_hits(new_bin.get_hits())
                                new_bin_list.remove(new_bin)
                                break
                    if len(new_bin_list) != 0:
                        merged_covpt.set_bins_mismatch(True)
                    # Add any extra bins not found in previous files
                    merged_bin_list.extend(new_bin_list)
                    merged_covpt.set_invalid_bins(merged_bin_list)

                    # Update coverpoint's coverage counters
                    merged_covpt.set_number_of_valid_bins(num_valid_bins)
                    merged_covpt.set_number_of_covered_bins(num_covered_bins)
                    merged_covpt.set_total_bin_min_hits(total_bin_min_hits)
                    merged_covpt.increment_total_bin_hits(new_covpt.get_total_bin_hits())
                    merged_covpt.set_total_coverage_bin_hits(total_coverage_bin_hits)
                    merged_covpt.set_total_goal_bin_hits(total_goal_bin_hits)
                    merged_covpt.increment_number_of_tc_accumulated(1)
                    merged = True

            if merged is False:
                new_covpt.increment_number_of_tc_accumulated(1)
                self.merged_covpt_list.append(new_covpt)

    def print_covpt_report(self):
        print('Writing reports to {}'.format(self.output_file))
        for covpt in self.merged_covpt_list:
            if self.holes is True:
                covpt.print_report(self.output_file, 'HOLES')
            elif self.verbose is True:
                covpt.print_report(self.output_file, 'VERBOSE')
            else:
                covpt.print_report(self.output_file, 'NON_VERBOSE')

    def print_overall_report(self):
        if self.holes is True:
            self._print_overall_report('HOLES')
        elif self.verbose is True:
            self._print_overall_report('VERBOSE')
        else:
            self._print_overall_report('NON_VERBOSE')


    def print_bins_mismatch(self):
        if self.ignore_mismatch is False:
            txt = []
            color_txt = []
            found_covpts = False

            txt.append('\n' + 'Coverpoints with mismatching bins:')
            color_txt.append('\n' + bcolors.WARNING + 'Coverpoints with mismatching bins:' + bcolors.ENDC)
            for covpt in self.merged_covpt_list:
                if covpt.get_bins_mismatch() is True:
                    txt.append(covpt.get_name())
                    color_txt.append(bcolors.WARNING + covpt.get_name() + bcolors.ENDC)
                    found_covpts = True
            if found_covpts is False:
                txt.append('None')
                color_txt.append(bcolors.OKGREEN + 'None' + bcolors.ENDC)

            with open(self.output_file, mode='a') as output_file:
                for line in txt:
                    output_file.write(line + '\n') # Print to file
                for line in color_txt:
                    print(line)                    # Print to terminal


if __name__ == '__main__':
    cm = CoverageMerger()
    cm.merge()
    cm.print_covpt_report()
    cm.print_overall_report()
    cm.print_bins_mismatch()
