#!/bin/bash
vagrant up | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }'

