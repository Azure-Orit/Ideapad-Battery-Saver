class MyWindow : Gtk.ApplicationWindow {

    internal MyWindow (MyApplication app) {
        Object (application: app, title: "Ideapad Battery Saver");

        this.border_width = 20;

        var label = new Gtk.Label ("Battery Threshold Status");
        var switcher = new Gtk.Switch ();

        switcher.set_active (true);

        switcher.notify["active"].connect (switcher_cb);

        var grid = new Gtk.Grid ();
        grid.set_column_spacing (10);
        grid.attach (label, 0, 0, 1, 1);
        grid.attach (switcher, 1, 0, 1, 1);

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
        window.icon = new Gdk.Pixbuf.from_file("../resources/icon.svg");
        window.show_all (); //show all the things
    }

    internal MyApplication () {
        Object (application_id: "org.example.checkbutton");
    }
}

int main (string[] args) {
    return new MyApplication ().run (args);
}
