from sys import argv as args
from sqlalchemy import create_engine
from blessings import Terminal
from os import system

import random
import string


class WPMaker:

    _APACHE = {
        'PATH': '/var/www/html/',
        'PORT': 80,
        'SA': '/etc/apache2/sites-available/'
    }

    _DRIVER = 'mysql'

    def __init__(self, site_name):
        self._user = 'root'
        self._psw = '12345'
        self._host = 'localhost'
        self._port = 3306
        self._name = site_name
        self._db = self._name.split('.')[0]

    def _connect(self):
        try:
            engine = create_engine('{driver}://{user}:{psw}@{host}:{port}/{driver}'.format(user=self._user,
                                                                                           psw=self._psw,
                                                                                           host=self._host,
                                                                                           port=self._port,
                                                                                           driver=self._DRIVER))
            self._conn = engine.connect()
            self._conn.execute('commit')
        except Exception as e:
            print(t.bold_red('Error trying to connect to {}, please verify your credentials'.format(self._DRIVER)))
            exit(1)

    def _build_db(self):
        self._connect()

        try:
            self._psw = ''.join([random.choice(string.ascii_letters + string.digits + string.punctuation) for n in range(18)])
            self._psw = self._psw.replace('%', '').replace('\\', '').replace('"', '')

            self._conn.execute('create database {}'.format(self._db))
            self._conn.execute('CREATE USER {}@{} IDENTIFIED BY "{}"'.format(self._db, self._host, self._psw))
            self._conn.execute('GRANT ALL PRIVILEGES ON {db} . * TO {db}@{host}'.format(db=self._db, host=self._host))

            self._conn.close()
        except Exception as e:
            print(t.bold_red('Error trying to build database'))
            exit(2)

    def _build_apache(self):
        try:
            with open('{}{}.conf'.format(self._APACHE['SA'], self._name), 'w') as vh:
                vh.write('<VirtualHost *:{PORT}> \n'
                         '\tServerAdmin webmaster@getout.com \n'
                         '\tServerName {page} \n'
                         '\tServerAlias www.{page} \n\n'
                         '\tDocumentRoot {PATH}{page} \n\n'
                         '\t<Directory /> \n'
                         '\t\tOptions FollowSymLinks \n'
                         '\t\tAllowOverride All \n'
                         '\t</Directory> \n'
                         '\t<Directory {PATH}{page}> \n'
                         '\t\tOptions Indexes FollowSymLinks MultiViews \n'
                         '\t\tAllowOverride All \n'
                         '\t\tOrder allow,deny \n'
                         '\t\tallow from all \n'
                         '\t</Directory> \n'
                         '</VirtualHost>'.format(page=self._name, **self._APACHE))

            system('a2ensite {} 1>/dev/null'.format(self._name))
            system('service apache2 restart 2>/dev/null')
        except Exception as e:
            print(t.bold_red('Error trying to build apache context:'), e.args)
            exit(3)

    def make(self):
        print(t.bold_blue('Building site...'))

        self._build_db()
        self._build_apache()

        system('clear')
        print(t.bold_green('Successfully created context for:\n'))
        print(t.bold('  Site:'), t.bold_cyan('\t' + self._name), '\n')
        print('', t.bold_underline('Database:\n'))
        print(t.bold('  User:'), t.bold_yellow('\t' + self._db))
        print(t.bold('  Password:'), t.bold_yellow('\t' + self._psw), '\n')


if __name__ == '__main__':
    t = Terminal()

    if len(args) is 1:
        print('Usage of wp-maker:\n')
        print('\twp-maker [site-name]\n')
    else:
        maker = WPMaker(args[1])
        maker.make()
