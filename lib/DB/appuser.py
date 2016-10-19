
# eatout - yummy places in the hood
# Copyright (C) 2014-2016 Maria Carrasco Rodriguez
#
# This file is part of eatout.
#
# eatout is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# eatout is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with eatout.  If not, see <http://www.gnu.org/licenses/>.

#
#  appuser.py : Class representing an user
#
# Written in 2014 by Maria Carrasco  <kostspielig@gmail.com>
#


import random
import hashlib
from string import letters

from google.appengine.ext import db


##### user stuff
def make_salt(length = 5):
    return ''.join(random.choice(letters) for x in xrange(length))

def make_pw_hash(name, pw, salt = None):
    if not salt:
        salt = make_salt()
    h = hashlib.sha256(name + pw + salt).hexdigest()
    return '%s,%s' % (salt, h)

def valid_pw(name, password, h):
    salt = h.split(',')[0]
    return h == make_pw_hash(name, password, salt)

def users_key(group = 'default'):
    return db.Key.from_path('users', group)

class User(db.Model):
    """ Class representing an user."""

    #Attributes for a user
    name = db.StringProperty(required = True)
    pw_hash = db.StringProperty(required = True)
    description = db.StringProperty()
    email = db.StringProperty(required = True)
    website = db.StringProperty()
    avatar = db.BlobProperty()

    #users are also assigned a art_posts reference property.


    @classmethod
    def by_id(cls, uid):
        return User.get_by_id(uid, parent = users_key())

    @classmethod
    def by_name(cls, name):
        u = User.all().filter('name =', name).get()
        return u

    @classmethod
    def by_email(cls, name):
        e = User.all().filter('email =', name).get()
        return e

    @classmethod
    def register(cls, name, pw, description=None ,email = None, website = None, avatar = None):
        pw_hash = make_pw_hash(name, pw)
        return User(parent = users_key(),
                    name = name,
                    pw_hash = pw_hash,
                    description = description,
                    email = email,
                    website = website,
                    avatar = avatar)

    @classmethod
    def login(cls, name, pw):
        u = cls.by_name(name)
        if u and valid_pw(name, pw, u.pw_hash):
            return u
