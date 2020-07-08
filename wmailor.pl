#!/usr/bin/perl

use Mail::IMAPClient;
use Config::Settings;


my $settings = Config::Settings->new->parse_file ("myapp.settings");

# returns an unconnected Mail::IMAPClient object:
my $imap = Mail::IMAPClient->new;

# intervening code using the 1st object, then:
# (returns a new, authenticated Mail::IMAPClient object)

my $host = $settings->{imap}->{server};
my $user = $settings->{user}->{user};
my $pass = $settings->{user}->{pass};

$imap = Mail::IMAPClient->new(  
                Server => $host,
                User    => $user,
                Password=> $pass,
                Clear   => 5,   # Unnecessary since '5' is the default
                Uid => 1,
)       or die "Cannot connect to $host as $id: $@";

$Authenticated = $imap->Authenticated();
$Connected = $imap->Connected();

print "auth: $Authenticated\n";
print "Connected $Connected\n";

$imap->search('SUBJECT',$imap->Quote("(no subject)"));

print join(", ",$imap->folders),".\n";

print join(", ",$imap->folders("Archives" . $imap->separator),".\n");

my @raw_output = $imap->list(@args)  or die "Could not list: $@\n";

foreach (@raw_output)
{
  print;
}

$imap->select("Inbox");

my @msgs = $imap->messages or die "Could not messages: $@\n";
foreach (@msgs)
{
  print $_ . "\n";
}

for my $h (values %{$imap->parse_headers( scalar($imap->search("ALL")) , "Subject", "Date")}) {
  print map {"$_:\t$h->{$_}[0]\n"} keys %$h;
}

$imap->disconnect or warn "Could not disconnect: $@\n";
