class MyWindow : Gtk.ApplicationWindow {
    internal MyWindow (MyApplication app) {
        Object (application: app, title: "Ideapad Battery Saver");
        this.border_width = 20;
        var bat_threshold = new Gtk.Label ("Battery Threshold Status");
		var charge_cycles = new Gtk.Label ("Charge Cyles");
		var charge_cycles_value = new Gtk.Label ("");
        var switcher = new Gtk.Switch ();
        File conservation_mode = File.new_for_path ("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
        File cycle_count = File.new_for_path ("/sys/class/power_supply/BAT0/cycle_count");
		FileInputStream @is = conservation_mode.read ();
		DataInputStream dis = new DataInputStream (@is);        
		string line;
		while ((line = dis.read_line ()) != null) {
			if (int.parse (line) == 1){
				switcher.set_active (true);
            	}
	}

        switcher.notify["active"].connect (switcher_cb);
        var grid = new Gtk.Grid ();
        grid.set_column_spacing (10);
		grid.set_row_spacing (10);
        grid.attach (bat_threshold, 0, 0, 1, 1);
        grid.attach (switcher, 1, 0, 1, 1);
		grid.attach (charge_cycles, 0, 1, 1, 1);
		grid.attach (charge_cycles_value, 1, 1, 1, 1);
        this.add (grid);
        
}

void switcher_cb (Object switcher, ParamSpec pspec) {
	if ((switcher as Gtk.Switch).get_active())
        	Posix.system("echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
        else
        	Posix.system("echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
	}
}

class MyApplication : Gtk.Application {
	protected override void activate () {
        	var window = new MyWindow (this);
        	window.icon = new Gdk.Pixbuf.from_file("/usr/local/share/BatterySaver/icon.svg");
        	window.show_all (); //show all the things
        	window.resizable = false;
    	}
    	internal MyApplication () {
        	Object (application_id: "com.github.Azure-Orit.Ideapad-Battery-Saver");
    	}
}

int main (string[] args) {
    	return new MyApplication ().run (args);
}
