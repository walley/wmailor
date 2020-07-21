# wmailor
tui mail client


currently just a compilation of examples, but it does stuff!


uses:
* Curses::UI
* Mail::IMAPClient
* Config::Settings


# myapp.settings

user {
  user "user";
  pass "pass";
};

smtp {
  server "192.168.1.1";
};


imap {
  server "192.168.1.2";
};

