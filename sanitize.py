def sanitize_mountain_data():
    # Open file for reading/write back later
    f = open('mtn-locs.txt', 'r+')

    final_set = set()
    while True:
        line1 = f.readline()
        line2 = f.readline()
        if not line2: break

        location = (int(float(line1.strip())), int(float(line2.strip())))
        final_set.add(location)

    f.close()
    print final_set
    out_file = open('mtn-locs-cleaned.txt', 'w')
    for i in final_set:
        out_file.write(str(i[0]) + " " + str(i[1]) + "\n")


if __name__ == "__main__":
    sanitize_mountain_data()
