def find_authors():
    #Authors ids to be searched
    b = [2280, 1842]

    with open('icalp_id_author.txt', encoding = "ISO-8859-1") as f:
        datafile = f.readlines()
    for i in b:
        for line in datafile:
            line = line.strip()
            line = line.lower()
            columns = line.split(' ')
            id = int(columns[0])
            if i == id:
                print(listToString(columns[1:]))
               
find_authors()
