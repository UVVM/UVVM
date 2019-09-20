from PyPDF2 import PdfFileReader, PdfFileWriter
from PyPDF2.generic import NameObject, createStringObject
import os


class PdfEditor(object):

    def __init__(self, root_directory):
        self.root_directory = root_directory

    # This function will search for PDF files in all subdirectories in the "root_directory" and change their meta data.
    # The Title will be replaced by the file name
    # The Author and Producer fields will be set to Bitvis AS
    def run(self):
        print("Starting renaming of PDF files")
        for subdir, dirs, files in os.walk(self.root_directory):
            for file in files:
                if file.endswith(".pdf"):
                    print("Fixing metadata of PDF file " + file)
                    filename, file_extension = os.path.splitext(file)
                    filepath = subdir + '\\' + file
                    self.change_metadata(filepath, filename, 'Bitvis AS', 'Bitvis AS')

    @staticmethod
    def change_metadata(pdf, title, producer, author):
        file_in = open(pdf, 'rb')
        pdf_in = PdfFileReader(file_in, strict=False)

        writer = PdfFileWriter()

        for page in range(pdf_in.getNumPages()):
            writer.addPage(pdf_in.getPage(page))

        info_dict = writer._info.getObject()

        info = pdf_in.documentInfo
        for key in info:
            info_dict.update({NameObject(key): createStringObject(info[key])})

        # Change the title, producer and author
        info_dict.update({NameObject('/Title'): createStringObject(title)})
        info_dict.update({NameObject('/Producer'): createStringObject(producer)})
        info_dict.update({NameObject('/Author'): createStringObject(author)})

        # It does not appear possible to alter in place.
        file_out = open(pdf+'out.pdf', 'wb')
        writer.write(file_out)
        file_in.close()
        file_out.close()

        # Replace the original file with the new file
        os.unlink(pdf)
        os.rename(pdf+'out.pdf', pdf)

        # Printout for debugging
        #pdf_read = PdfFileReader(open(pdf, 'rb'))
        #print(pdf_read.getDocumentInfo())
        #print(pdf_read.getDocumentInfo()['/Title'])
        #print(pdf_read.getDocumentInfo()['/Producer'])
        #print(pdf_read.getDocumentInfo()['/Author'])

