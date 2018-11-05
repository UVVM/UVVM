from pdf_editor import PdfEditor
import os, sys

class MetaDataEditor(object):
    ''' For replacing meta data in PDF files '''
    
    def __init__(self, pdf_file='Bitvis'):
        ''' Locate PDF file directory '''
        self.path = os.path.dirname(__file__)
        self.path = os.getcwd()
        self.pdf_file = os.path.relpath('..\\doc\\' + pdf_file, self.path)
        

    def debug(self):
        ''' Debug '''
        return self.pdf_file
    

    def set_meta_data(self, title='Bitvis', producer='Bitvis AS', author='Bitvis AS'):
        ''' Select meta data, call PdfEditor and replace PDF meta data '''
        self.title = title
        self.producer = producer
        self.author = author
        self.editor = PdfEditor(self.pdf_file)
        self.editor.change_metadata(self.pdf_file, self.title, self.producer, self.author)



