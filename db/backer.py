from _cffi_backend import string
from string import ascii_letters, printable
from textwrap import wrap
from uuid import uuid4
from subprocess import call

import pickle
import os

import sys


class Encoder:

    def __init__(self):
        self._alphabet = {'0': 'b831', '1': 'fde8', '2': 'e51a', '3': '9dad', '4': 'ac42', '5': '837a', '6': '70c4', '7': '8d9a', '8': '2284', '9': '5d34', 'a': 'f990', 'b': '1103', 'c': 'fa40', 'd': 'fa2f', 'e': 'dfb8', 'f': '518f', 'g': 'a179', 'h': 'bc34', 'i': 'd97c', 'j': '8518', 'k': '16fb', 'l': '75a0', 'm': 'd923', 'n': 'bcc2', 'o': '5696', 'p': '8d43', 'q': '6d4a', 'r': '6285', 's': 'f93e', 't': 'ca6a', 'u': '8625', 'v': '9313', 'w': '54e2', 'x': 'c6ee', 'y': 'a373', 'z': 'e687', 'A': '1087', 'B': '7472', 'C': 'a8a0', 'D': '1620', 'E': '4004', 'F': '7171', 'G': 'f21c', 'H': 'ce6d', 'I': 'a8ae', 'J': '0b92', 'K': 'de3c', 'L': '2abc', 'M': 'ff18', 'N': 'fd97', 'O': 'f45d', 'P': '9ef6', 'Q': '52ec', 'R': '1fa0', 'S': 'a2ec', 'T': 'c711', 'U': '6b6d', 'V': 'f5f6', 'W': 'ef1e', 'X': '0878', 'Y': '026d', 'Z': '2119', '!': '946b', '"': '934a', '#': 'ad6f', '$': 'e9df', '%': '4f63', '&': '10f2', "'": 'e7a7', '(': 'b2d2', ')': 'c45f', '*': '63f5', '+': '4337', ',': '343e', '-': 'e1f7', '.': '3016', '/': 'faf6', ':': '34c6', ';': 'ae05', '<': '98cd', '=': '5fcf', '>': '723b', '?': '1ef6', '@': 'dd78', '[': '2599', '\\': 'fbb2', ']': '0c2c', '^': 'ecaf', '_': 'f1b9', '`': '3be1', '{': '0ef2', '|': '2b44', '}': '76fe', '~': 'cee5', ' ': 'ebe0'}
        self._messy = ''
        self._encoded = ''
        self._decoded = ''

    def alphabet_generator(self):
        self._alphabet = {}

        for char in printable:
            self._alphabet[char] = uuid4().hex[0:4]

    def mess_up(self, text):
        upper = round(len(text) / 2)
        downer = 0
        count = 0

        for i in text:
            self._messy += text[downer] if count % 2 else text[upper]

            downer += 1 if count % 2 else 0
            upper += 0 if count % 2 else 1
            count += 1

    def encode(self, text):
        self.mess_up(text)

        for char in self._messy:
            self._encoded += self._alphabet[char]

        return self._encoded

    def decode(self, text):
        deciphered = ''

        try:
            for part in wrap(text, 4):
                deciphered += list(self._alphabet.keys())[list(self._alphabet.values()).index(part)]

            count = 0
            for i in deciphered:
                self._decoded += i if count % 2 else ''
                count += 1

            count = 0
            for i in deciphered:
                self._decoded += i if not count % 2 else ''
                count += 1

        except Exception:
            print('That text is not encoded by me or it was built with a different alphabet')

        return self._decoded


if __name__ == '__main__' and len(sys.argv) > 2:

    args = {}
    for i in range(len(sys.argv) - 1):
        if i % 2 and i < len(sys.argv):
            args[sys.argv[i]] = sys.argv[i + 1]
        else:
            args[sys.argv[i]] = 0

    print(args)

    pickle.dump({'user': 'pedrito', 'pass': 'testing'}, open('/backer-db/pedrito.pkl', 'wb'))
    pickle.dump({'user': 'ana', 'pass': 'testing'}, open('/backer-db/ana.pkl', 'wb'))
    data = pickle.load(open('/backer-db/pedrito.pkl', 'rb'))
    print(data['user'])

else:
    print("error: Argumentos inválidos \n")
    print("backer usage: backer [ dbname1 dbname2 ... dbnameN ] \n")
    print("	dbnameX: Nombre de las bases de datos a respaldar \n")
# os.system('mysqldump -u $USER --routines --opt chatadmin > /db_`date +%d-%m-%Y`.sql')