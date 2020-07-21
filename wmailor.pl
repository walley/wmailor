#!/usr/bin/perl

use Mail::IMAPClient;
use Config::Settings;

use Curses::UI;

my $imap;
my $settings;
my $win_folders;

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


my $menu = $cui->add(
             'menu','Menubar',
             -menu => \@menu,
             -bg  => "green",
             -fg  => "black",
             );


my $win_mail = $cui->add('win_mail', 'Window',
  -border => 1,
  -y    => 1,
  -bfg  => 'red',
  -padleft => 20,
  -height => 20,
);

my $texteditor = $win_mail->add("text", "TextEditor",
  -vscrollbar => 1,
  -wrapping   => 1,
  -text => "Here is some text ^X to activate menu ^Q to quit\n",
  -showlines => 1,
  -showhardreturns => 1,
);
my $label = $win_mail->add(
    'mylabel', 'Label',
    -text      => 'Hello, world!',
    -bold      => 1,
);


@values = ("a","b");
$win_folders= $cui->add('list_window', 'Window',
  -padtop => 1,
  -width => 20,
);

my $ml = $win_folders->add('message_list', 'Listbox',
   -values => \@values,
   -labels => \%labels,
   -vscrollbar => 1,
   -wraparound => 1,
   -border => 1,
   -ipad   => 1,
   -title  => 'Inbox',
);

#$win_folders->add(
#    undef, 'Label',
#    -height => $win_folders->height,
#    -width => $win_folders->width,
#    -text  => 'inbox',
#    -textalignment => 'middle',
#    -bold  => 1,
#);

$values[2] = "c";
push (@values, "x");


&main_stuff();

################################################################################
sub main_stuff()
################################################################################
{
  &load_settings();
  &imap_login();
  my @f = &imap_folders();
push (@values, @f);

  &create_ui();
}

################################################################################
sub create_ui()
################################################################################
{
  $cui->set_binding(sub {$menu->focus()}, "\cX");
  $cui->set_binding(\&exit_dialog, "\cQ");
  $texteditor->text(&mailstuff());
  $texteditor->focus();
  $cui->mainloop();
}



################################################################################
sub imap_folders()
################################################################################
{
  $imap->select("Inbox");
  $out .= join(", ",$imap->folders),".\n";
  $out .= join(", ",$imap->folders("Archives" . $imap->separator),".\n");
  return $imap->folders;
}

################################################################################
sub load_settings()
################################################################################
{
  $settings = Config::Settings->new->parse_file ("myapp.settings");
}

################################################################################
sub imap_login()
################################################################################
{
  my $host = $settings-> {imap} -> {server};
  my $user = $settings-> {user} -> {user};
  my $pass = $settings-> {user} -> {pass};

  $imap = Mail::IMAPClient->new (
            Server => $host,
            User    => $user,
            Password=> $pass,
            Clear   => 5,   # Unnecessary since '5' is the default
            Uid => 1,
          )       or die "Cannot connect to $host as $id: $@";

  $Authenticated = $imap->Authenticated();
  $Connected = $imap->Connected();
}

################################################################################
sub mailstuff()
################################################################################
{

  my $out = "IMAP STUFF\n";

  $out .= "auth: $Authenticated\n";
  $out .= "Connected $Connected\n";

  $imap->search('SUBJECT',$imap->Quote("(no subject)"));


  my @raw_output = $imap->list(@args)  or die "Could not list: $@\n";

  foreach (@raw_output) {
    $out .= $_;
  }


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

################################################################################
sub exit_dialog()
################################################################################
{
  my $return = $cui->dialog(
                 -message   => "Do you really want to quit?",
                 -title     => "Are you sure???",
                 -buttons   => ['yes', 'no'],
               );

  exit(0) if $return;
}

################################################################################
sub save_dialog()
################################################################################
{
#  my $dialog = $cui->add(
#    'mydialog', 'Dialog::Filebrowser'
#  );
#  $dialog->focus;
#  my $file = $dialog->get();
#$cui->delete('mydialog');

  my $file = $cui->savefilebrowser();
}
