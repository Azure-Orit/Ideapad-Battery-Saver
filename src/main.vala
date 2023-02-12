class MyWindow : Gtk.ApplicationWindow {
    internal MyWindow (MyApplication app) {
        Object (application: app, title: "Ideapad Battery Saver");
        this.border_width = 20;
        var bat_threshold = new Gtk.Label ("Battery Threshold Status");
		bat_threshold.set_xalign (0);
		var charge_cycles = new Gtk.Label ("Charge Cyles");
		charge_cycles.set_xalign (0);
		var bat_lvl = new Gtk.Label ("Battery Level");
		bat_lvl.set_xalign (0);
		var bat_status = new Gtk.Label ("Current State");
		bat_status.set_xalign (0);
        var switcher = new Gtk.Switch ();
        File conservation_mode = File.new_for_path ("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
		FileInputStream @fis0 = conservation_mode.read ();
		DataInputStream dis0 = new DataInputStream (@fis0);        
		string line;
		while ((line = dis0.read_line ()) != null) {
			if (int.parse (line) == 1){
				switcher.set_active (true);
            	}
		}
		File cycle_count = File.new_for_path ("/sys/class/power_supply/BAT0/cycle_count");
		FileInputStream @fis1 = cycle_count.read ();
		DataInputStream dis1 = new DataInputStream (@fis1); 
		string string_cycles = dis1.read_line ();
		var charge_cycles_value = new Gtk.Label (string_cycles);
		charge_cycles_value.set_xalign (0);
		File capacity = File.new_for_path ("/sys/class/power_supply/BAT0/capacity");
		FileInputStream @fis2 = capacity.read ();
		DataInputStream dis2 = new DataInputStream (@fis2); 
		string string_capacity = dis2.read_line ();
		var capacity_value = new Gtk.Label (string_capacity);
		capacity_value.set_xalign (0);
		File status = File.new_for_path ("/sys/class/power_supply/BAT0/status");
		FileInputStream @fis3 = status.read ();
		DataInputStream dis3 = new DataInputStream (@fis3); 
		string string_status = dis3.read_line ();
		var status_value = new Gtk.Label (string_status);
		status_value.set_xalign (0);

        switcher.notify["active"].connect (switcher_cb);
        var grid = new Gtk.Grid ();
		
        grid.set_column_spacing (10);
		grid.set_row_spacing (10);
		grid.attach (bat_lvl, 0, 0, 1, 1);
		grid.attach (capacity_value, 1, 0, 1, 1);
		grid.attach (bat_status, 0, 1, 1, 1);
		grid.attach (status_value, 1, 1, 2, 1);
		grid.attach (charge_cycles, 0, 2, 1, 1);
		grid.attach (charge_cycles_value, 1, 2, 1, 1);
        grid.attach (bat_threshold, 0, 3, 1, 1);
        grid.attach (switcher, 1, 3, 1, 1);

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
