#!/usr/bin/python
############################################################################
# This script will run through all components listed in component_list.txt
# and update the file versions.txt in the root directory with the version
# found in version.txt in the component directory.
#
# By Arild Reiersen, Bitvis AS
############################################################################

import os

def main():

	versions_file = open("../versions.txt", "w+")

	header = "This project uses the following versions:"

	versions_file.write(header)

	with open("component_list.txt", "r") as components:
		line = components.readline()
		while line:
			component = line.strip()
			component_version = "\n  " + component + ", version v" + return_version(component)
			versions_file.write(component_version)
			line = components.readline()

	versions_file.close()
	print("versions.txt have been updated")


def return_version(component):
	with open("../" + component + "/version.txt", "r") as version_file:
		version = version_file.readline().strip()
	return version


if __name__ == '__main__':
	main()