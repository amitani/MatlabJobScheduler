#!/bin/bash
kill $(ps aux|grep [a]mitani|grep [M]ATLAB|grep [s]ingle|awk '{print $2}') 
