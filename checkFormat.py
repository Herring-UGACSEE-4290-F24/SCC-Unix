import csv

memoryOut = open("memoryOut.txt", "r")
memoryFormatted = open("memoryFormatted.csv", "w")

csvData = [
    ['Address', 'Value']
]

words = [];
word = ""

address = 0
hexAddress = 0
lineCount = 0

lines = [line.strip() for line in memoryOut.readlines()]
for line in lines:
    if (line.find("//") == -1):
        word = word + line
        lineCount = lineCount + 1
        if (lineCount == 4):
            words.append(word)
            word = ""
            lineCount = 0

for bytes in words:
    hexAddress = hex(address).upper().replace("X", "x")
    while(len(hexAddress) != 10):
        hexAddress = hexAddress[0:2] + "0" + hexAddress[2:len(hexAddress)]

    if (bytes == "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"):
        csvData.append([hexAddress, '0x00000000'])
    else:
        instruction = hex(int(bytes, 2)).upper().replace("X", "x")
        while(len(instruction) != 10):
            instruction = instruction[0:2] + "0" + instruction[2:len(instruction)]
        csvData.append([hexAddress, instruction])
    address = address + 4

csv.writer(memoryFormatted).writerows(csvData)

memoryOut.close()
memoryFormatted.close()