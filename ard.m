% =========================================================
% Project: Smart Parking Management System
% Author: Taarun Dev Karthikeyan
%
% Date: 22-11-2022
% Time: 2pm
% Desc.: A smart technology that helps and manages car 
%   traffic while parked. In the actual world, if we need 
%   to park, we must first seek a parking place by driving 
%   around the parking lot. Because the system is aware of 
%   all available slots, it directs the user to the 
%   designated parking place. If no slots are available, 
%   the user will be notified.
% =========================================================

% Clear existing memory
clear;
% Clear screen
clc;

% Print INIT for MATLAB
disp('@Taarz');
disp('Smart Parking Management Initialized');
disp('Press Ctrl+C to stop');

% Arduino object
a = arduino('COM3','Uno','Libraries',{'LCD/LCDAddon','Servo'}); % Arduino Connection + Library import for Arduino

% LCD object
lcd = addon(a,'LCD/LCDAddon','RegisterSelectPin','D13','EnablePin','D12','DataPins',{'D5','D4','D3','D2'}); 
initializeLCD(lcd);

% Constants
RED = 'D8';
GREEN = 'D7';
ON = 1;
OFF = 0;
availablity = ["0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101"] ;
availableSlots = 13;
parked = string;
pin = [];
isExitPressed = false;
welcomeMSG = true;

% Servo Object
gate = servo(a,"D10");
writePosition(gate,0);

while true

    %init buttons
    enter = readVoltage(a,'A1');
    exit = readVoltage(a,'A2');
    zero = readVoltage(a,'A3');
    one = readVoltage(a,'A4');

    %init singal color RED
    writeDigitalPin(a,RED,ON);

    parked(cellfun('isempty',parked)) = [];

    % Welcome Message
    if ~isExitPressed && welcomeMSG
        clearLCD(lcd);
        printLCD(lcd,'Welcome!');
        printLCD(lcd, strcat('Slot avail.: ', num2str(availableSlots)));
        welcomeMSG = false;
    end
    
    % On press of ENTER button
    if enter>=4
        clearLCD(lcd);
        if ~isempty(availablity)
            availableSlots = availableSlots - 1;
            writeDigitalPin(a,RED,OFF);
            writeDigitalPin(a,GREEN,ON);
            writePosition(gate,0.5);

            parked(end+1) = string(availablity(1));
            clearLCD(lcd);
            printLCD(lcd, strcat('Parking ID: ', num2str(availablity(1))));
            printLCD(lcd, strcat('Slot avail.: ', num2str(availableSlots)));
            availablity = availablity(2:end);
            pause(3);
            writePosition(gate,0);
            writeDigitalPin(a,GREEN,OFF);
            writeDigitalPin(a,RED,ON);
        else
            clearLCD(lcd);
            printLCD(lcd, 'Parking Full!');
            printLCD(lcd, 'Please ComeLater');
            pause(3);
        end
       welcomeMSG = true;
    end   
    % On press of EXIT button
    if exit>=4
        isExitPressed = true;
        pin = [];
        clearLCD(lcd);
        printLCD(lcd,'Enter Pin');
        printLCD(lcd, num2str(pin));
        welcomeMSG = true;
    end
    % Zero button functionality
    if zero>=4 && isExitPressed
       pin = [pin, OFF];
       clearLCD(lcd);
       printLCD(lcd, num2str(pin));
    end
    % One button functionality
    if one>=4 && isExitPressed
       pin = [pin, ON];
       clearLCD(lcd);
       printLCD(lcd, num2str(pin));
    end
    % Exit Logic
    if length(pin) == 4 && isExitPressed
        if length(parked) > 0
            oldSize = length(parked);
            parked = erase(parked, strrep(join(string(pin)),' ',''));
            parked(cellfun('isempty',parked)) = [];
            if length(parked) < oldSize
                availableSlots = availableSlots + 1;
                availablity(end+1) = strrep(join(string(pin)),' ','');
                clearLCD(lcd);
                printLCD(lcd, 'Thank You!!');
                writeDigitalPin(a,RED,OFF);
                writeDigitalPin(a,GREEN,ON);
                writePosition(gate,0.5);
                pause(3);
                writePosition(gate,0);
                writeDigitalPin(a,GREEN,OFF);
                writeDigitalPin(a,RED,ON);
            else
                clearLCD(lcd);
                printLCD(lcd, 'Incorrect ID');
                pause(3);
            end
        else
            clearLCD(lcd);
            printLCD(lcd, 'NoVehicle in lot');
            pause(3);
        end
        isExitPressed = false;
        welcomeMSG = true;
    end 
end