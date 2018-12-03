#!/bin/bash
if [ -n "$RELOAD_CONTAINERS" ]
then
	docker container restart $RELOAD_CONTAINERS;
fi

