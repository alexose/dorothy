# Dorothy Sensor

The Dorothy Sensor platform is a simple, 3d printable case that houses a
[Heltec Cubecell](https://heltec.org/project/htcc-ab01-v2/) board, three battery cells, and one of three different types
of sensors.

It is designed to live outdoors, and can tolerate any environment that PLA can handle. With the correct sealant, it
should be able to operate underwater.

For measuring high heat environemnts, consider either printing in ABS or mounting the sensing element on a long wire.

## Materials

Begin by sourcing all of the necessary materials:

-   One [Heltec Cubecell AB01 V2](https://heltec.org/project/htcc-ab01-v2/)
-   One of the following sensors:
    -   [DHT22 Temperature/Humidity Sensor](https://www.amazon.com/dht22/s?k=dht22)
    -   [US-100 Ultrasonic Distance Sensor](https://www.amazon.com/s?k=us100+sensor&ref=nb_sb_noss)
    -   [I2C Soil Moisture Sensor](https://www.tindie.com/products/miceuz/i2c-soil-moisture-sensor/)
-   Three [18650 Lithium Ion cells](https://www.amazon.com/CWUU-Rechargeable-Battery-Headlamp-Flashlight/dp/B0CLY51NFH)
-   [Solid core wire](https://www.amazon.com/TUOFENG-Hookup-Wires-6-Different-Colored/dp/B07TX6BX47)

## 3D Printing

Use your favorite 3D printing software to print the following parts:

-   The [outer shell](https://github.com/alexose/3D-Printing/blob/main/Dorothy/sensor/outer_shell.stl)
-   A "brain" that matches your sensor type, e.g.,
    [distance_brain.stl](https://github.com/alexose/3D-Printing/blob/main/Dorothy/sensor/distance_brain.stl)
-   The [Cylindrical Battery Pack](https://www.thingiverse.com/thing:6080710)
-   Some short [M2 screws](https://www.amazon.com/HanTof-Washers-Assortment-Machine-Stainless/dp/B082XRX17Z)

You'll see that the housing is threaded. This allows for quick and easy assembly/disassembly of the device with no
tools.

## Assembly

Begin by connecting your choice of sensor to the CubeCell board. Typically, I just solder directly to it, but you may
want to attach headers first.

(Fritzing diagrams coming soon...)

Next, attach the board and the sensor to the "brain" mount. Note that there are various form factors depending on the
sensor type, but they typically involve a couple of M2 screws and some press-fitting.

Build the battery pack according to the [directions](https://www.thingiverse.com/thing:6080710). You may want to use
JST-type connectors, however, I find it somewhat difficult to disconnect those tiny connectors when everything is
mounted. Depending on your application, you might prefer to use
[this style](https://www.amazon.com/Pluggable-Connectors-Universal-Terminals-Wire-Stripping/dp/B07PRZMYD4) of
quick-connects to allow for easy swapping of battery packs.

## Flashing

Connect your Heltec CubeCell board to your computer using a USB cable. Using the
[Arduino IDE](https://www.arduino.cc/en/software/), open the .ino file that matches the sensor type you're using. For
example, if you're using a distance sensor, open up
[Dorothy_Distance.ino](https://github.com/alexose/3D-Printing/blob/main/Dorothy/sensor/code/Dorothy_Distance/Dorothy_Distance.ino).

Click the "upload" button to send the code to your cubecell device. After it restarts, it should begin sending messages
to your hub. This may be a good time to verify that your sensor is working correctly by reading the serial output of the
device.

You may now disconnect the device from your computer, connect it to the battery pack, and screw everything together.

Congratulations, you're now ready to place your sensor in its desired location and observe the readings over time!
