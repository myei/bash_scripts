# List of commands examples for using mongo


# Create root -> Mongo 2
db.createUser({
    user: "ADMIN",
    pwd: "PSW",
    roles: [
              { role: "userAdminAnyDatabase", db: "admin" },
              { role: "readWriteAnyDatabase", db: "admin" },
              { role: "dbAdminAnyDatabase", db: "admin" },
              { role: "clusterAdmin", db: "admin" }
           ]
});

# Create root -> Mongo 3
use admin;
db.createUser({ user: "ADMIN", pwd: "PSW", roles: ["root"] });

# Create owner of database
use tw_management;
db.createUser({ user: "USEROWNER", pwd: "PSW", roles: ["dbOwner"] });

# Starting and accesing
sudo mongod --auth --dbpath /var/lib/mongodb
mongo -u superman -p --authenticationDatabase "admin"
