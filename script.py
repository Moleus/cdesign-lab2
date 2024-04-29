file = open("lfsr2", "r")
lines = file.readlines()

numbers = set([int(num.strip()) for num in lines])
all_numbers = set(range(256))
missing_numbers = all_numbers - numbers

count_missing = len(missing_numbers)
print(missing_numbers)
print((256 - count_missing) / 256 * 100)
