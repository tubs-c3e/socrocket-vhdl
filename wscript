#! /usr/bin/env python
# vim : set fileencoding=utf-8 expandtab noai ts=4 sw=4 filetype=python :
top = '..'
REPOSITORY_PATH = "vhdl"
REPOSITORY_NAME = "SoCRocket VHDL Repository"
REPOSITORY_DESC = """Adds a vhdl grlib design used as template for the leon3mp platform"""
REPOSITORY_TOOLS = []

def build(self):
  self.recurse_all()
  self.recurse_all_tests()
