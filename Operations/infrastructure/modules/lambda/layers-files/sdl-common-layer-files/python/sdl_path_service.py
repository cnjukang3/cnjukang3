"""
This module is intended to be a utility for generating the
SDL specific paths in the S3 bucket for storing the different data sets
by following the correct path convention
"""

class SdlPathService:
    """Component for aiding in constructing SDL S3 specific paths"""
    def __init__(self, fisma_systems, datacenter, prefix, path):
        self.fisma_systems = fisma_systems
        self.datacenter = datacenter
        self.path = path
        self.prefix = prefix
        self.default = None

    def build_datacenter(self, datacenter, datacenters):
        """Set datacenter and fisma systems for a particular data center"""
        if datacenter in datacenters:
            self.datacenter = datacenters.get(datacenter).get("datacenter")
            self.fisma_systems = datacenters.get(datacenter).get("fisma_systems")
            self.default = datacenters.get(datacenter).get("default")

    def get_fisma_system(self, account):
        """Find and return the fisma system that corresponds to the
        provided account numnber"""
        for fisma_system in self.fisma_systems:
            if account in fisma_system.get("accounts"):
                return fisma_system.get("fisma_system")
        return self.default

    def build_key(self, account, source_type):
        """Build the S3 path for where to write the source_type json file."""
        fisma_system = self.get_fisma_system(account)
        fisma_uid = fisma_system.get('UID')
        acronym = None
        if fisma_system.get('Acronym'):
            acronym = (fisma_system.get("Acronym").replace(" - ", "-").replace(" ", "-").lower())
        path_part = "/".join(filter(None, [fisma_uid, acronym, self.prefix]))
        #print('Build Path: ', path_part)
        return f"{self.path}{self.datacenter}/{path_part}/accountid={account}/{source_type}.json.gz"
