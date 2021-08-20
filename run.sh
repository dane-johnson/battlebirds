#!/usr/bin/bash

if [ "$1" == "two" ]
then
    godot --path godot --scene Demo/JoinLocalNoMenu.tscn &
    sleep 2
    i3-msg '[class="Battle Birds"]' move position 0 0
fi

godot --path godot --scene Demo/HostNoMenu.tscn  
