_awesome_quit = awesome.quit
-- Override awesome.quit when we're using GNOME
awesome.quit = function()
   if os.getenv("DESKTOP_SESSION") == "awesome-gnome" then
      os.execute("/usr/bin/gnome-session-quit  --logout --no-prompt")
   else
      _awesome_quit()
   end
end
