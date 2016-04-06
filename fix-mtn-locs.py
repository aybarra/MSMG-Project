def sanitize_mountain_data():
    # Open file for reading/write back later
    f = open('mtn-locs-cleaned.txt', 'r+')

    final_list = []
    for line in f:
        final_list.append([int(x) for x in line.split()])
    f.close()
    print final_list

    print "\n"
    # final_list.sort(key=lambda x: x[1]) 
    final_list.sort(key=lambda x: x[0])
    # sorted(final_list, key = lambda x: (sum(x), x[0]))
    print final_list
    # print final_set
    out_file = open('mtn-locs-cleaned-fixed.txt', 'w')
    for i in final_list:
        out_file.write(str(i[0]) + " " + str(i[1]) + "\n")


if __name__ == "__main__":
    sanitize_mountain_data()
