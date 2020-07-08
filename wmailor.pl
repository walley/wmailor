#!/usr/bin/perl

use Mail::IMAPClient;
use Config::Settings;

use Curses::UI;

my $cui = new Curses::UI( -color_support => 1 );

my @menu = (
  {
    -label => 'File',
    -submenu => [
      { -label => 'Save      ^S', -value => \&save_dialog  },
      { -label => 'Exit      ^Q', -value => \&exit_dialog  },
    ]
  },
  {
    -label => 'Edit',
    -submenu => [
     {-label => 'User settings...', -value => \&user_dialog},
     {-label => 'IMAP settings...', -value => \&imap_dialog},
     {-label => 'SMTP settings...', -value => \&smtp_dialog},
    ]
  },
  {
    -label => 'Help',
    -submenu => [
     { -label => 'About...', -value => \&about_dialog  }
    ]
  },
);

sub exit_dialog()
{
  my $return = $cui->dialog(
                 -message   => "Do you really want to quit?",
                 -title     => "Are you sure???",
                 -buttons   => ['yes', 'no'],

               );

  exit(0) if $return;
}

sub save_dialog()
{
#  my $dialog = $cui->add(
#    'mydialog', 'Dialog::Filebrowser'
#  );
#  $dialog->focus;
#  my $file = $dialog->get();
#$cui->delete('mydialog');

  my $file = $cui->savefilebrowser();


}

my $menu = $cui->add(
             'menu','Menubar',
             -menu => \@menu,
             -bg  => "green",
             -fg  => "black",
             );

my $win_folders = $cui->add(
             'win_folders', 'Window',
             -border => 1,
             -y    => 1,
             -bfg  => 'red',
    -width  => 15,
    -height => 5,
             );

my $win_mail = $cui->add(
             'win_mail', 'Window',
             -border => 1,
             -y    => 1,
             -bfg  => 'red',
    -padtop => 5,
    -height => 20,

             );

my $texteditor = $win_mail->add(
                   "text", "TextEditor",
                   -vscrollbar => 1,
                   -wrapping   => 1,
                   -text => "Here is some text ^X to activate menu ^Q to quit\n",
                   -showlines => 1,
                   -showhardreturns => 1,
                   );

$cui->set_binding(sub {$menu->focus()}, "\cX");
$cui->set_binding( \&exit_dialog, "\cQ");
$texteditor->text(&mailstuff());
$texteditor->focus();
$cui->mainloop();


sub mailstuff()
{

  my $out = "IMAP STUFF\n";

  my $settings = Config::Settings->new->parse_file ("myapp.settings");

# returns an unconnected Mail::IMAPClient object:
  my $imap = Mail::IMAPClient->new;

# intervening code using the 1st object, then:
# (returns a new, authenticated Mail::IMAPClient object)

  my $host = $settings-> {imap}-> {server};
  my $user = $settings-> {user}-> {user};
  my $pass = $settings-> {user}-> {pass};

  $imap = Mail::IMAPClient->new (
            Server => $host,
            User    => $user,
            Password=> $pass,
            Clear   => 5,   # Unnecessary since '5' is the default
            Uid => 1,
          )       or die "Cannot connect to $host as $id: $@";

  $Authenticated = $imap->Authenticated();
  $Connected = $imap->Connected();

  $out .= "auth: $Authenticated\n";
  $out .= "Connected $Connected\n";

  $imap->search('SUBJECT',$imap->Quote("(no subject)"));

  $out .= join(", ",$imap->folders),".\n";

  $out .= join(", ",$imap->folders("Archives" . $imap->separator),".\n");

  my @raw_output = $imap->list(@args)  or die "Could not list: $@\n";

  foreach (@raw_output) {
    $out .= $_;
  }

  $imap->select("Inbox");

  my @msgs = $imap->messages or die "Could not messages: $@\n";

  foreach (@msgs) {
    $out .=  $_ . "\n";
  }

  for my $h (values % {$imap->parse_headers( scalar($imap->search("ALL")), "Subject", "Date")}) {
    $out .=  map {"$_:\t$h->{$_}[0]\n"} keys %$h;
  }

  $imap->disconnect or warn "Could not disconnect: $@\n";

  return $out;
}
