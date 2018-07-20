from sys import argv as args
from sqlalchemy import create_engine
from blessings import Terminal
from os import system, makedirs

import random
import string


class WPMaker:

    APACHE = {
        'path': '/var/www/html/',
        'port': 80,
        'sa': '/etc/apache2/sites-available/'
    }

    DB = {
        'user': 'root',
        'psw': '12345',
        'host': 'localhost',
        'port': 3306,
        'driver': 'mysql'
    }

    def __init__(self, site_name):
        self._name = site_name
        self._db = self._name.split('.')[0]

    def _connect(self):
        try:
            engine = create_engine('{driver}://{user}:{psw}@{host}:{port}/{driver}'.format(**self.DB))
            self._conn = engine.connect()
            self._conn.execute('commit')
        except Exception as e:
            print(t.bold_red('Error trying to connect to {}, please verify your credentials'.format(self.DB['driver'])))
            exit(1)

    def _build_db(self):
        self._connect()

        try:
            self._psw = ''.join([random.choice(string.ascii_letters + string.digits + string.punctuation) for n in range(18)])
            self._psw = self._psw.replace('%', '').replace('\\', '').replace('"', '')

            self._conn.execute('CREATE DATABASE {}'.format(self._db))
            self._conn.execute('CREATE USER {}@{} IDENTIFIED BY "{}"'.format(self._db, self.DB['host'], self._psw))
            self._conn.execute('GRANT ALL PRIVILEGES ON {db} . * TO {db}@{host}'.format(db=self._db, host=self.DB['host']))
        except Exception as e:
            print(t.bold_red('Error trying to build database'), e.args)
            exit(2)

    def _rollback_db(self):
        self._conn.execute('DROP DATABASE {}'.format(self._db))
        self._conn.execute('DROP USER {}@{}'.format(self._db, self.DB['host']))

    def _build_apache(self):
        try:
            makedirs(self.APACHE['path'] + self._name, exist_ok=True)

            with open('{}{}.conf'.format(self.APACHE['sa'], self._name), 'w') as vh:
                vh.write('<VirtualHost *:{port}> \n'
                         '\tServerAdmin webmaster@getout.com \n'
                         '\tServerName {page} \n'
                         '\tServerAlias www.{page} \n\n'
                         '\tDocumentRoot {path}{page} \n\n'
                         '\t<Directory /> \n'
                         '\t\tOptions FollowSymLinks \n'
                         '\t\tAllowOverride All \n'
                         '\t</Directory> \n'
                         '\t<Directory {path}{page}> \n'
                         '\t\tOptions Indexes FollowSymLinks MultiViews \n'
                         '\t\tAllowOverride All \n'
                         '\t\tOrder allow,deny \n'
                         '\t\tallow from all \n'
                         '\t</Directory> \n'
                         '</VirtualHost>'.format(page=self._name, **self.APACHE))

            system('a2ensite {} 1>/dev/null'.format(self._name))
            system('service apache2 restart 2>/dev/null')
        except Exception as e:
            self._rollback_db()
            print(t.bold_red('Error trying to build apache context, rolling back database changes...'), e.args)
            exit(3)

    @staticmethod
    def yes_or_no(question):
        try:
            choices = {'y': True, 'n': False}
            choice = str(input(t.bold_yellow(question + ' (y/n): '))).lower().strip()

            return choices.get(choice) if choice in choices else WPMaker.yes_or_no(question)
        except:
            print(t.bold_red('\n\nERROR: you must type y or n'))
            exit(4)

    def _clean(self):
        self._conn.close()
        system('clear')

    def make(self):
        if not self.yes_or_no('Are you sure about creating this site: ' + t.bold_cyan_italic(self._name) + '?'):
            exit(5)

        print(t.bold_blue('Building site...'))

        self._build_db()
        self._build_apache()

        self._clean()

        print(t.bold_green('Successfully created context for:\n'))
        print(t.bold('  Site:'), t.bold_cyan('\t' + self._name))
        print(t.bold('  Path:'), t.bold_cyan('\t' + self.APACHE['path'] + self._name), '\n')
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
