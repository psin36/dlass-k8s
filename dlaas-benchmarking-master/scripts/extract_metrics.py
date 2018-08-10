#!/usr/bin/env python
import datetime
import os
import sys
import subprocess

# Created by: Parijat Dube

def extract_datetime_from_line(line, year):
    # Expected format: I0210 13:39:22.381027 25210 solver.cpp:204] Iteration 100, lr = 0.00992565
    line = line.strip().split()
    month = int(line[0][1:3])
    day = int(line[0][3:])
    timestamp = line[1]
    pos = timestamp.rfind('.')
    ts = [int(x) for x in timestamp[:pos].split(':')]
    hour = ts[0]
    minute = ts[1]
    second = ts[2]
    microsecond = int(timestamp[pos + 1:])
    dt = datetime.datetime(year, month, day, hour, minute, second, microsecond)
    return dt

def extract_iteration_from_line(line):
	line = line.strip().split()
	return int(line[5].split(",")[0])

def extract_accuracy_from_line(line):
	line = line.strip().split()
	return float(line[10])

def extract_loss_from_line(line):
        line = line.strip().split()
	return float(line[10])

def get_log_created_year(input_file):
    """Get year from log file system timestamp
    """

    log_created_time = os.path.getctime(input_file)
    log_created_year = datetime.datetime.fromtimestamp(log_created_time).year
    return log_created_year


def get_start_time(line_iterable, year):
    """Find start time from group of lines
    """

    start_datetime = None
    for line in line_iterable:
        line = line.strip()
        if line.find('Solving') != -1:
            start_datetime = extract_datetime_from_line(line, year)
            break
    return start_datetime


#def extract_seconds_iteration_accuracy_loss(input_file, output_file):
def extract_metrics(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    log_created_year = get_log_created_year(input_file)
    start_datetime = get_start_time(lines, log_created_year)
    assert start_datetime, 'Start time not found'

    last_dt = start_datetime
    out = open(output_file, 'w')
    set_iteration = None
    for line in lines:
        line = line.strip()
	# get iteration #
        if (line.find('Iteration')!=-1) & (line.find('Testing') != -1):
	    set_iteration = True
	    iteration_count = extract_iteration_from_line(line)
	# get accuracy
	if (line.find('Test net output #0') != -1) and set_iteration:
	    # get timestamp when accuracy is printed
            dt = extract_datetime_from_line(line, log_created_year)
            # if it's another year
            if dt.month < last_dt.month:
                log_created_year += 1
                dt = extract_datetime_from_line(line, log_created_year)
            last_dt = dt

            elapsed_seconds = (dt - start_datetime).total_seconds()
	    accuracy = extract_accuracy_from_line(line)
	# get loss
	if (line.find('Test net output #1') != -1) and set_iteration:
	    loss = extract_loss_from_line(line)
	    textString = '{:d} {:f} {:f} {:f}'.format(iteration_count,elapsed_seconds,accuracy,loss)
            #out.write('%d\t%f\t%f\t%f\n' % iteration_count % elapsed_second % accuracy % loss)
	    out.write(textString+'\n')
	    set_iteration = False
    out.close()

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print('Usage: ./extract_metrics model_id log_file output_file mode(0/1)')
        exit(1)
    #os.system("bx dl logs training-2q5JbP7zR > 1_1.log")
    #commandString = ["bx dl logs", sys.argv[1], ">", sys.argv[2]]
    print (sys.argv[4])
    if(sys.argv[4]=="0"):
      commandString ="bx dl logs "+sys.argv[1]+ " > "+sys.argv[2]
      print(commandString)
    #subprocess.call(commandString)
      os.system(commandString)
    extract_metrics(sys.argv[2], sys.argv[3])
