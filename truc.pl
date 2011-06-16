#!/usr/bin/perl


# Pour se connecter à la SQL
use DBI();
#
# ################################
# ### Données de configuration ###
# ################################
# # Driver SQL à utiliser
$dbdriver = "mysql";
#
# # Base où est stockée la DNS
$dbbase = "xnet";
#
# # User avec lequel se connecter
$dbuser = "xnet";
#
# # Mot de passe pour cette base
$dbpass = "Bo<uLet";
#
# # Serveur SQL
$dbhost = "localhost";
#
# # Table dans laquelle est stockée la DNS
$dbdns = "DNS";
#
# # Table dans laquelle est sotcké le reverse_DNS
$dbreversedns = "reverse_DNS";
#
# # Table du xnet
$dbxnet = "clients";
#
# # Suffixe DNS
$dnssuffixe = "eleves.polytechnique.fr";

my $db = DBI->connect("DBI:$dbdriver:database=$dbbase:host=$dbhost",
                $dbuser, $dbpass, {PrintError=>1, AutoCommit => 1}
		        );

# Incrémentation du sérial
print "done\n* Incrémentation du sérial... ";
$entree = $db->prepare("select rdata from $dbdns where name like '$dnssuffixe' and rdtype = 'SOA'");
$entree->execute;
($soa) = $entree->fetchrow();

if($soa =~ /^(.*) (\d+) (\d+) (\d+) (\d+) (\d+)$/) {
     $serial = $2 + 1;
     print "$2 -> $serial...";
    $soa = "$1 $serial $3 $4 $5 $6";
   $db->do("update $dbdns set rdata = '$soa' where rdtype = 'SOA'");
      $db->do("update $dbreversedns set rdata = '$soa' where rdtype = 'SOA'");
}
