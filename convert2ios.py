import os
import fileinput
import sys

current_dir = os.getcwd()
file_list = [
        r'src/MAVRIC2.mxml',
        r'src/com/transcendss/mavric/extended/models/CaptureBar.as',
        r'src/com/transcendss/mavric/views/componentviews/MainEntryForm.mxml',
        r'src/skins/TSSBusySkin1.mxml'
    ]
blockFlag = False
for f in file_list:
    temp_file = os.path.join(current_dir, f)
    try:
        for line in fileinput.input(temp_file, inplace=1):
            if not blockFlag:
                if 'import' in line and 'GPSHandler' in line:
                    if line.strip()[:2] != '//':
                        line = '//' + line
                elif 'import' in line and 'GPSData' in line:
                    if line.strip()[:2] != '//':
                        line = '//' + line
                elif 'var' in line and ':GPSData' in line:
                    if line.strip()[:2] != '//':
                        line = '//' + line
                elif 'var' in line and ':GPSHandler' in line:
                    if line.strip()[:2] != '//':
                        line = '//' + line
                elif 'loading2.swf' in line:
                    if line.strip()[:2] != '//':
                        line = '//' + line
                elif 'scale' in line and 'busyIndicator' in line:
                    line = line.replace('true', 'false')
                elif 'mx:SWFLoader' in line:
                    line = '<util:AnimatedGIFImage id="loader" source="images/loading.gif"/>'
                elif '///Comment out in ios' in line:
                    blockFlag = True
            else:
                if '///End Comment out in ios' not in line:
                    if line.strip()[:2] != '//':
                        line = '//' + line
                else:
                    blockFlag = False
            sys.stdout.write(line)
        
    except:
        os.remove(temp_file)
        os.rename(os.path.splitext(temp_file)[0] + ".bak", temp_file)
