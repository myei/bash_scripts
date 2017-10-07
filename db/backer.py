from _cffi_backend import string
from math import trunc
from string import ascii_letters, printable
from textwrap import wrap
from uuid import uuid4
from blessings import Terminal
from termcolor import colored

import pickle
import os
import sys
import subprocess


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
        upper = round(len(text) / 2) if not len(text) % 2 else trunc(len(text) / 2)
        downer = 0
        count = 0

        self._messy = ''
        for i in text:
            self._messy += text[downer] if count % 2 else text[upper]

            downer += 1 if count % 2 else 0
            upper += 0 if count % 2 else 1
            count += 1

    def encode(self, text):
        self.mess_up(text)

        self._encoded = ''
        for char in self._messy:
            self._encoded += self._alphabet[char]

        return self._encoded

    def decode(self, text):
        deciphered = ''

        try:
            self._decoded = ''
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

    def json_encode(self, json):
        _json = {}

        for i in json:
            _json[i] = self.encode(json[i])

        return _json

    def json_decode(self, json):
        _json = {}

        for i in json:
            _json[i] = self.decode(json[i])

        return _json


class Backup:

    pool_path = '/var/backer-db/'

    defs = {
        'mysql': {
            'port': '3306',
            'host': 'localhost'
        },
        'mongodb': {
            'port': '27017',
            'host': 'localhost'
        }
    }

    def __init__(self, pool, db_name):
        self.pool_name = pool
        self.db_name = db_name
        self.pool = {}

        os.system('mkdir -p ' + Backup.pool_path)

    def make(self):
        pool = self.get_pool()

        if bool(pool):
            actions = {
                'mysql': 'mysqldump -u ' + pool['user'] + ' --password="' + pool['psw'] +
                          '" -P ' + pool['port'] + ' --routines --opt ' + self.db_name + ' > ' +
                          Backup.pool_path + pool['name'] + '/' + self.db_name + '_`date +%d-%m-%Y`.sql &>/dev/null',
                'mongodb': 'mongodump --host ' + pool['host'] + ' --port ' + pool['port'] + ' --db ' + self.db_name +
                          ' -u ' + pool['user'] + ' -p ' + pool['psw'] + ' --authenticationDatabase "admin" --out ' +
                          Backup.pool_path + pool['name'] + '/' + self.db_name + '_`date +%d-%m-%Y` &>/dev/null'
            }

            os.system(actions.get(pool['engine']))

        else:
            print(t.bold_red('There is no pool named: ' + self.pool_name + ', please add it'))

    @staticmethod
    def list():
        if subprocess.getoutput(['ls ' + Backup.pool_path + ' | cut -f 1 -d "." | sort | wc -l']) == '0':
            print(t.bold_yellow('No tiene pools registrados'))
        else:
            print(t.bold_green(subprocess.getoutput(['ls ' + Backup.pool_path + ' | cut -f 1 -d "." | sort'])))

    @staticmethod
    def create_pool():
        try:
            pool = {}
            print(t.bold_cyan('Ingrese la información de su nuevo pool: \n'))

            pool['name'] = Backup.validate(input(t.bold_yellow('Nombre: ')))

            print(t.bold_yellow('Seleccione su manejador: \n'))

            pools = list(Backup.defs)
            for item in range(len(pools)):
                print('   [' + t.bold_cyan(str(item)) + "]", pools[item])

            p = input(t.bold_yellow('\nIngrese su selección: '))

            pool['engine'] = pools[int(p)] if p != '' and int(p) < len(pools) else Backup.validate('')
            pool['user'] = Backup.validate(input(t.bold_yellow('Usuario: ')))
            pool['psw'] = Backup.validate(input(t.bold_yellow('Password: ')))
            pool['host'] = Backup.validate(input(t.bold_yellow('Hostname [' + Backup.defs[pool['engine']].get('host') +
                                                               ']: ')), Backup.defs[pool['engine']].get('host'))
            pool['port'] = Backup.validate(input(t.bold_yellow('Puerto [' + Backup.defs[pool['engine']].get('port') +
                                                               ']:')), Backup.defs[pool['engine']].get('port'))

            os.system('mkdir -p ' + Backup.pool_path + pool['name'])
            pickle.dump(Encoder().json_encode(pool), open(Backup.pool_path + pool['name'] + '.pkl', 'wb'))
        except Exception:
            pass

    def get_pool(self):
        try:
            enc = Encoder()

            self.pool = pickle.load(open(Backup.pool_path + self.pool_name + '.pkl', 'rb'))
            self.pool = enc.json_decode(self.pool)

        except Exception:
            pass

        return self.pool

    def remove_pool(self):
        subprocess.getoutput(['rm ' + Backup.pool_path + self.pool_name + '.pkl'])

    @staticmethod
    def validate(_in, default=None):
        if len(_in) > 0:
            return _in
        elif default is not None:
            return default
        else:
            print(t.bold_red('Debe ingresar este campo'))
            exit(2)

    @staticmethod
    def usage():
        print("error: Argumentos inválidos \n")
        print("backer usage: backer [ dbname1 dbname2 ... dbnameN ] \n")
        print("	dbnameX: Nombre de las bases de datos a respaldar \n")
        exit()


if __name__ == '__main__' and len(sys.argv) > 1:

    t = Terminal()

    args = {}
    _args = sys.argv

    for i in range(len(_args)):
        if i % 2 and i < len(_args) - 1:
            args[_args[i]] = _args[i + 1]
        elif i == len(_args) - 1 and not len(_args) % 2:
            args[_args[i]] = 0

    def_args = {
        'pool': ['-p', '--pool'],
        'db': ['-db', '--databases']
    }

    if '--create-pool' in args or '-cp' in args:
        Backup.create_pool()
    elif '--list-pools' in args or '-lp' in args:
        Backup.list()
    elif '--remove-pool' in args or '-rp' in args:
        Backup.remove_pool()
    else:
        requests = [ii for ii in args.keys()]
        for ii in requests:
            found = ([i for i in def_args if ii in def_args[i]])

            if len(found) == 0:
                Backup.usage()

            def_args[found[0]] = args[ii]

        backup = Backup(def_args['pool'], def_args['db'])
        backup.make()

    # backup = Backup(p, args['-db'])
    # print(backup.get_pool())

else:
    Backup.usage()
    print('a')
