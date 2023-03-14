using Gtk;

class MyWindow : ApplicationWindow {
	private Label bat_threshold;
	private Label charge_cycles;
	private Label bat_lvl;
	private Label bat_status;
	private Switch switcher;
	private Label bat_health;
	private Label charge_cycles_value;
	private ProgressBar capacity_value;
	private Label status_value;
	private ProgressBar percentage_value;
    internal MyWindow (MyApplication app) {
        Object (application: app, title: "Ideapad Battery Saver");
        this.border_width = 20;
        bat_threshold = new Label ("Battery Threshold Status");
		bat_threshold.set_xalign (0);
		charge_cycles = new Label ("Charge Cyles");
		charge_cycles.set_xalign (0);
		bat_lvl = new Label ("Battery Level");
		bat_status = new Label ("Current State");
		bat_status.set_xalign (0);
		bat_health = new Label ("Battery Health");
		capacity_value = new ProgressBar ();
		charge_cycles_value = new Label ("");
		status_value = new Label ("");
		percentage_value = new ProgressBar ();
        switcher = new Switch ();
        File conservation_mode = File.new_for_path ("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
		FileInputStream @fis0 = conservation_mode.read ();
		DataInputStream dis0 = new DataInputStream (@fis0);        
		string line;
		while ((line = dis0.read_line ()) != null) {
			if (int.parse (line) == 1){
				switcher.set_active (true);
            	}
		}
		Timeout.add(50, () => {
			File cycle_count = File.new_for_path ("/sys/class/power_supply/BAT0/cycle_count");
			FileInputStream @fis1 = cycle_count.read ();
			DataInputStream dis1 = new DataInputStream (@fis1); 
			string string_cycles = dis1.read_line ();
			charge_cycles_value.set_label (string_cycles);
			return true;
		});
		Timeout.add(50, () => {
			File capacity = File.new_for_path ("/sys/class/power_supply/BAT0/capacity");
			FileInputStream @fis2 = capacity.read ();
			DataInputStream dis2 = new DataInputStream (@fis2); 
			string string_capacity = dis2.read_line ();
			double capacity_double = double.parse (string_capacity);
			double energy = capacity_double/100;
			capacity_value.set_fraction (energy);
			capacity_value.set_show_text (true);
			return true;
		});
		Timeout.add(50, () => {
			File status = File.new_for_path ("/sys/class/power_supply/BAT0/status");
			FileInputStream @fis3 = status.read ();
			DataInputStream dis3 = new DataInputStream (@fis3); 
			string string_status = dis3.read_line ();
			status_value.set_label (string_status);
			return true;
		});
		Timeout.add(50, () => {
			File energy_full = File.new_for_path ("/sys/class/power_supply/BAT0/energy_full");
			FileInputStream @fis4 = energy_full.read ();
			DataInputStream dis4 = new DataInputStream (@fis4); 
			string string_energy_full = dis4.read_line ();
			float double_energy_full = float.parse (string_energy_full);
			File energy_full_design= File.new_for_path ("/sys/class/power_supply/BAT0/energy_full_design");
			FileInputStream @fis5 = energy_full_design.read ();
			DataInputStream dis5 = new DataInputStream (@fis5); 
			string string_energy_full_design = dis5.read_line ();
			float double_energy_full_design = float.parse (string_energy_full_design);
			float 100_times = double_energy_full*100;
			float x = 100_times/double_energy_full_design;
			float x_rounded = Math.roundf(x * 100) / 100;
			float x_100 = x_rounded/100;
			percentage_value.set_fraction (x_100);
			percentage_value.set_show_text (true);
			return true;
		});
		

        switcher.notify["active"].connect (switcher_cb);
        var grid = new Grid ();
		
        grid.set_column_spacing (30);
		grid.set_row_spacing (10);
		grid.attach (bat_lvl, 0, 0, 3, 1);
		grid.attach (capacity_value, 0, 1, 3, 1);
		grid.attach (bat_status, 0, 2, 1, 1);
		grid.attach (status_value, 1, 2, 2, 1);
		grid.attach (charge_cycles, 0, 3, 1, 1);
		grid.attach (charge_cycles_value, 1, 3, 2, 1);
		grid.attach (bat_health, 0, 4, 3, 1);
		grid.attach (percentage_value, 0, 5, 3, 1);
        grid.attach (bat_threshold, 0, 6, 1, 1);
        grid.attach (switcher, 2, 6, 1, 1);

        this.add (grid);
        
}

void switcher_cb (Object switcher, ParamSpec pspec) {
	if ((switcher as Switch).get_active())
        	Posix.system("echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
        else
        	Posix.system("echo 0 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
	}
}

class MyApplication : Gtk.Application {
	protected override void activate () {
        	var window = new MyWindow (this);
        	window.icon = new Gdk.Pixbuf.from_file("/usr/local/share/BatterySaver/icon.svg");
			window.set_default_size (200, 80);
        	window.show_all (); //show all the things
        	window.resizable = false;
    	}
    	internal MyApplication () {
        	Object (application_id: "com.github.Azure-Orit.Ideapad-Battery-Saver");
    	}
}


int main (string[] args) {
	MyApplication app = new MyApplication();
   	return app.run (args);
}

