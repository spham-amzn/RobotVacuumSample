#!/bin/bash

COMMAND=$1

BASE=$(cd `dirname $0` && pwd)

if [ "$COMMAND" = "" ]
then
    echo "RobotVacuum Script usage:"
    echo "./demo.sh [COMMAND]"
    echo
    echo "COMMAND (launch|rviz|editor|build)"
    echo
    echo "Example:  Launch the Simulation:"
    echo "  ./demo.sh launch"
    echo
    echo "Example:  Launch RViz:"
    echo "  ./demo.sh rviz"
    echo
    echo "Example:  Launch the Editor:"
    echo "  ./demo.sh editor"
    echo
    echo "Example:  Build:"
    echo "  ./demo.sh build"
    echo
    exit 0
fi

source /opt/ros/humble/setup.bash

if [ "$COMMAND" = "launch" ]
then
    # Kill any AssetBuilder Process
    for i in $(ps -ef | grep AssetBuilder | grep -v grep | awk '{print $2}')
    do
        echo Killing AssetBuilder $i
        kill -9 $i
    done

    ros2 daemon stop

    ros2 daemon start

    echo Launching Robot Vacuum Demo Simulation

    $BASE/build/linux/bin/profile/./RobotVacuumSample.GameLauncher -bg_ConnectToAssetProcessor=0 > /dev/null
    exit $?

elif [ "$COMMAND" = "rviz" ]
then

    cd $BASE/launch

    ros2 launch navigation.launch.py
elif [ "$COMMAND" = "editor" ]
then
    ros2 daemon stop

    ros2 daemon start

    echo Launching Editor for Robot Vacuum Demo

    $BASE/build/linux/bin/profile/Editor > /dev/null
    exit $?
elif [ "$COMMAND" = "build" ]
then

    echo Building the Robot Vacuum Demo and assets

    cd $BASE
    
    cmake -B $BASE/build/linux -G "Ninja Multi-Config" -S $BASE -DLY_DISABLE_TEST_MODULES=ON -DLY_STRIP_DEBUG_SYMBOLS=ON -DAZ_USE_PHYSX5=ON
    if [ ?$ -ne 0 ]
    then
        echo "Error building"
        exit 1
    fi

    cmake --build $BASE/build/linux --config profile --target Editor RobotVacuumSample.GameLauncher RobotVacuumSample.Assets

    exit 0 

else
    echo "Invalid Command $COMMAND"
fi

