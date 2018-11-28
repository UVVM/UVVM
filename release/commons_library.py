#!/usr/bin/python
############################################################################
# This script will run all simulations for this component
#
# By Arild Reiersen, Bitvis AS
############################################################################

import os

class Logger:
  def __init__(self, log_to_transcript):
    self.log_to_transcript = log_to_transcript
    self.log_message = ""

  def log(self, message):
    if self.log_to_transcript:
      print(message, flush=True)
    self.log_message += message

  def get_log(self):
    return self.log_message