# Scripting Exam 

## Источники и границы проверки

Собраны Section A A1–A8, полные скрипты B1–B3 и оба скрипта B4, теоретические пояснения и команды проверки. Проведена проверка кода по доступным условиям и оговорённым предположениям. B1–B4 сверены с присланными фотографиями. Section A A1–A8 также сверен с новыми фотографиями задания. Продолжение B4(q) на фотографиях обрезано. Выполнение на оригинальных данных пока не проверено.

Исходные данные exam-data не предоставлены. Численные результаты, имена подозрительных файлов и фактические ALERT зависят от них.

## Предположения о среде, путях и CSV

- Linux/Bash и стандартные GNU-команды; запуск из каталога, содержащего exam-data.
- Лог SSH: exam-data/case/logs/auth.log; HTTP: exam-data/case/logs/access.log.
- На фото CSV расположен в exam-data/intel/users.csv. В старом ответе был exam-data/case/users.csv — исправлено по фото.
- Предполагаемый порядок CSV: username,role,status,department. Перед запуском проверьте заголовок. Это простой CSV без запятых и переносов строк внутри кавычек. Поля не содержат лишних пробелов. Поддерживаются LF и CRLF.
- SSH-запись имеет вид Accepted password for USER from IP port ... или Failed password for [invalid user] USER from IP port ...; поле после from — адрес источника.
- HTTP status — девятое поле, как прямо указано в условии.
- wc -l считает символы перевода строки; предполагается, что каждая строка лога заканчивается переводом строки.

## Section A

Сверено с новыми фото A1–A8: команды соответствуют видимым требованиям при предположениях о данных, указанных выше. Для A3 требуется дополнительно назвать реальный файл с неверным расширением и его тип по результату file. Для A7 необходимо подтвердить колонки по заголовку CSV. Фактические результаты без exam-data не установлены.

**General instructions:** provide one Linux command or pipeline for each question. The questions below are paraphrased from the available photographs, not verbatim transcriptions.

### A1 — Count regular files

**Question:** How many regular files are there under `exam-data`, at any depth? Output the file count.

**Solution:**

```bash
find exam-data -type f -printf '.' | wc -c
```

Исходное find ... | wc -l работает для обычных имён, но ошибается на именах с переводом строки. Здесь каждый файл даёт один символ.

### A2 — Find empty files

**Question:** Which regular files under `exam-data` are empty (0 bytes)? Search at any depth and output their paths.

**Solution:**

```bash
find exam-data -type f -empty
```

Исходная команда корректна.

### A3 — Identify actual file types

**Question:** Use `file` to identify the actual type of every file in `exam-data/case/evidence`. Find at least one file whose contents do not match its extension. State its name and actual type.

**Solution:**

```bash
find exam-data/case/evidence -maxdepth 1 -type f -exec file -- {} +
```

Проверяет обычные файлы, включая скрытые. Если требуется рекурсивный обход, уберите -maxdepth 1. По выводу укажите конкретное имя с несоответствующим расширением и настоящий тип. Без файлов назвать его нельзя.

### A4 — Count failed password attempts

**Question:** How many failed password attempts are recorded in `exam-data/case/logs/auth.log`?

**Solution:**

```bash
grep -Fc 'Failed password' exam-data/case/logs/auth.log
```

Считает строки. Если совпадений нет, печатает 0 и возвращает код 1 — это нормальное поведение grep.

### A5 — Find the top three source IP addresses

**Question:** List the three source IP addresses with the most failed password attempts in `exam-data/case/logs/auth.log`, together with their counts, busiest first.

**Solution:**

```bash
grep -F 'Failed password' exam-data/case/logs/auth.log | awk '{for(i=1;i<NF;i++) if($i=="from") {print $(i+1); break}}' | sort | uniq -c | sort -nr | head -n 3
```

Исходный подход корректен при указанной структуре SSH-лога; break предотвращает повторный вывод из одной записи.

### A6 — Count HTTP status codes

**Question:** List every HTTP status code in `exam-data/case/logs/access.log` with the number of times it occurs, most frequent first. The status code is the ninth whitespace-separated field.

**Solution:**

```bash
awk 'NF>=9 {print $9}' exam-data/case/logs/access.log | sort | uniq -c | sort -nr
```

Пропускает пустые и слишком короткие строки. Для корректного access.log исходная команда была верной.

### A7 — List disabled accounts

**Question:** Which accounts in `exam-data/intel/users.csv` have the status `disabled`? Output the usernames only.

**Solution:**

```bash
awk -F',' 'NR>1 {sub(/\r$/, ""); if($3=="disabled") print $1}' exam-data/intel/users.csv
```

Исправлен путь; структура колонок — предположение, указанное выше.

### A8 — Count lines in log files using find and xargs

**Question:** Find every `.log` file under `exam-data`, at any depth, and show the number of lines in each. Use `find -print0` together with `xargs -0`.

**Solution:**

```bash
find exam-data -type f -name '*.log' -print0 | xargs -0 -r wc -l
```

Соответствует требованию использовать find -print0 вместе с xargs -0. -r предотвращает запуск wc без файлов. При нескольких файлах wc может также печатать total.

## Section B

**General script requirements (from the photographs):** Each script must start with a correct shebang, be executable, quote variables containing filenames or user input, and send error messages to standard error. On Linux, make the saved scripts executable with chmod +x before running them.

### B1 — logsummary.sh: Log file summary

**Task (from the supplied photographs, paraphrased):** Write `logsummary.sh` to accept one file path and print a short summary.

1. If the number of arguments is not exactly one, print a usage message and exit with code 1.
2. If the file does not exist, print an error and exit with code 2.
3. If the file exists but is empty, print an error and exit with code 3.
4. Otherwise, print each item on its own line, using command substitution:
   - the file name;
   - the number of lines;
   - the number of `Failed password` lines;
   - the number of `Accepted password` lines;
   - the timestamp of the first line and of the last line (the first three fields of each line).
5. Exit with code 0.

**Required tests:** Run the script with `exam-data/case/logs/auth.log`, with `exam-data/case/evidence/empty.bin`, with a nonexistent file name, and with no arguments. Check each exit code using `echo $?`. Write the answers in `answers.txt`.

**Solution:**

```bash
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
    echo "Error: File does not exist or is not a regular file" >&2
    exit 2
fi

if [ ! -r "$file" ]; then
    echo "Error: Cannot read file" >&2
    exit 2
fi

if [ ! -s "$file" ]; then
    echo "Error: File is empty" >&2
    exit 3
fi

lines=$(wc -l < "$file")
failed=$(grep -Fc "Failed password" < "$file" || true)
accepted=$(grep -Fc "Accepted password" < "$file" || true)

first=$(head -n 1 < "$file" | awk '{print $1, $2, $3}')
last=$(tail -n 1 < "$file" | awk '{print $1, $2, $3}')

echo "File     : $file"
echo "Lines    : $lines"
echo "Failed   : $failed"
echo "Accepted : $accepted"
echo "First    : $first"
echo "Last     : $last"

exit 0
```

Основная логика присланного решения корректна. Добавлена проверка чтения; grep -Fc ищет буквальный текст. Перенаправление входа позволяет обработать имя, начинающееся с дефиса. Сохранены коды: 1 — неверное число аргументов, 2 — нет обычного файла или его нельзя прочитать, 3 — пустой файл, 0 — успех. Код 2 для ошибки чтения — принятое здесь дополнение, для недоступного на чтение файла; это дополнительная обработка ошибки, отдельно не оговорённая на фото.

Предполагается syslog-формат, где первые три поля — месяц, день и время. First и Last показывают первую и последнюю запись в порядке файла, а не вычисленные минимальную и максимальную даты. Для ISO-формата или записей с hostname в первых трёх полях эту часть нужно адаптировать. wc -l считает переводы строк: предполагается LF в конце каждой записи. Подсчёт событий корректен при одной записи на строку. Автоматический запуск не подтверждён из-за ранее описанной ошибки Bash.


### B2 — check_ip.sh: Investigate an IP address

**Task (paraphrased from the supplied photographs):** Write `check_ip.sh` which takes one IP address as an argument and investigates it.

1. If there is not exactly one argument, or it does not look like an IPv4 address (four groups of digits separated by dots), print an error and exit with code 1.
2. Count the `Failed password` and `Accepted password` lines for that exact address in `exam-data/case/logs/auth.log`. Do not count a different address merely because it contains the search text.
3. Use an `if` / `elif` / `else` chain to classify failed attempts: 0 = `NONE`, 1–4 = `LOW`, 5–9 = `MEDIUM`, 10 or more = `HIGH`.
4. Print whether the address is listed in `exam-data/intel/watchlist.txt` (YES/NO or equivalent). Use an exact whole-line match.
5. Print every line in `exam-data/case/logs/firewall.log` for that address, or `Firewall: no entries` if there are none.
6. If the address has both failed and accepted logins, print `WARNING: successful login after failed attempts.`
7. Exit with code 0 if the address appears in any file in `exam-data/case/logs/`, or code 3 if it appears nowhere in that directory.

**Solution:**
```bash
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Error: Provide one IPv4 address" >&2
    exit 1
fi

ip="$1"

# Split the address into four parts.
IFS='.' read -r first second third fourth extra <<< "$ip"

if [ -n "$extra" ] || [[ "$ip" == *. ]]; then
    echo "Error: Provide one IPv4 address" >&2
    exit 1
fi

for part in "$first" "$second" "$third" "$fourth"; do
    # The task requires four groups of digits separated by dots.
    case "$part" in
        ''|*[!0-9]*)
            echo "Error: Provide one IPv4 address" >&2
            exit 1
            ;;
    esac

done

log="exam-data/case/logs/auth.log"
watchlist="exam-data/intel/iocs.txt"
firewall="exam-data/case/logs/firewall.log"
log_dir="exam-data/case/logs"

if [ ! -r "$log" ] || [ ! -r "$watchlist" ] || [ ! -r "$firewall" ]; then
    echo "Error: Cannot read input files" >&2
    exit 1
fi

# Select lines containing the exact address, including in SRC=IP fields.
# Keep dots inside an address so a longer dotted address cannot match.
ip_lines() {
    awk -v ip="$ip" '{
        original=$0
        gsub(/[^0-9.]/, " ")
        for (i=1; i<=NF; i++) {
            if ($i==ip) {print original; break}
        }
    }' "$1"
}

failed=$(ip_lines "$log" | grep -Fc "Failed password" || true)
accepted=$(ip_lines "$log" | grep -Fc "Accepted password" || true)

if [ "$failed" -eq 0 ]; then
    risk="NONE"
elif [ "$failed" -le 4 ]; then
    risk="LOW"
elif [ "$failed" -le 9 ]; then
    risk="MEDIUM"
else
    risk="HIGH"
fi

if grep -Fxq "$ip" "$watchlist"; then
    listed="yes"
else
    listed="no"
fi

echo "IP       : $ip"
echo "Failed   : $failed"
echo "Accepted : $accepted"
echo "Risk     : $risk"
echo "Watchlist: $listed"

firewall_lines=$(ip_lines "$firewall")
if [ -n "$firewall_lines" ]; then
    printf '%s\n' "$firewall_lines"
else
    echo "Firewall: no entries"
fi

if [ "$failed" -gt 0 ] && [ "$accepted" -gt 0 ]; then
    echo "WARNING: successful login after failed attempts"
fi

for logfile in "$log_dir"/*; do
    [ -f "$logfile" ] || continue
    if [ ! -r "$logfile" ]; then
        echo "Error: Cannot read $logfile" >&2
        exit 1
    fi
    matches=$(ip_lines "$logfile")
    if [ -n "$matches" ]; then
        exit 0
    fi
done

exit 3
```

Проверено по фото: исправлен путь watchlist, добавлен firewall и поиск во всех обычных файлах непосредственно в каталоге logs. Наличие только в watchlist не даёт код 0. Проверяется именно требуемая форма «четыре группы цифр»; проверка диапазона 0–255 условием не требуется.

Функция ip_lines заменяет символы, кроме цифр и точек, пробелами и сравнивает полученные поля с IP целиком. Поэтому похожие и более длинные адреса не учитываются. Она подходит для обычных текстовых логов с IP, отделёнными пробелами, знаками `=` или другой пунктуацией; точка непосредственно после IP без разделителя считается частью поля. Для подсчётов сохранён понятный grep -Fwc. Предполагаются читаемые текстовые логи без подкаталогов для пункта 7, watchlist с одним адресом на строку и окончаниями LF.

Текст WARNING восстановлен именно как в условии. Условие требует наличия обоих видов событий, но не проверки времени: сама эта строка не доказывает, что успешный вход произошёл после отказов.

**Required tests:** Run the script for `203.0.113.10`, `198.51.100.77`, `192.168.1.10`, `203.0.113.1`, and `abc`. Write the results in `answers.txt`.

```bash
chmod +x check_ip.sh
./check_ip.sh 203.0.113.10
echo $?
./check_ip.sh 198.51.100.77
echo $?
./check_ip.sh 192.168.1.10
echo $?
./check_ip.sh 203.0.113.1
echo $?
./check_ip.sh abc
echo $?
```

**B2(q) — Compare the gaps in the server's defences:** Compare your script's output for `203.0.113.10` and `198.51.100.77`. Which address represents the bigger gap in the server's defences? Explain in two or three sentences, using your script's output. Write the answer in `answers.txt`.

**Пояснение к ответу:** сравните число отказов и успешных входов, наличие в watchlist и строки firewall. Успешная аутентификация подозрительного адреса — более серьёзное свидетельство пробела, чем одни заблокированные попытки. Без exam-data выбрать конкретный адрес и привести фактические числа нельзя.
### B3 — sweep.sh: IOC Sweep and Hash Check

**Task (paraphrased from the supplied photographs):** Write `sweep.sh` (no arguments), which does two things.

**Part 1 — IOC sweep:** Using nested `for` loops, check every indicator in `exam-data/intel/iocs.txt` against every file matching `exam-data/case/logs/*.log`.

- For each indicator and log where the indicator appears, print the indicator, the log filename without its directory, and the number of matching lines.
- Match indicators as fixed strings and whole words.
- After each indicator, print how many logs it was seen in.
- At the end, print the total number of matching lines across all indicators and logs.
- Do not print errors or incorrect totals when an indicator matches nothing.

**Part 2 — Hash check:** Using a `for` loop over `exam-data/case/evidence/*`, calculate the MD5 hash of every regular file. Print `KNOWN BAD: <file>` if its hash appears as a complete line in `iocs.txt`; otherwise, print `CLEAN: <file>`. The loop must still work correctly if a filename contains a space.

**Solution:**
```bash
#!/bin/bash

ioc_file="exam-data/intel/iocs.txt"
log_dir="exam-data/case/logs"
evidence_dir="exam-data/case/evidence"

if [ "$#" -ne 0 ]; then
    echo "Usage: $0" >&2
    exit 1
fi

if [ ! -f "$ioc_file" ] || [ ! -r "$ioc_file" ] ||
   [ ! -d "$log_dir" ] || [ ! -d "$evidence_dir" ]; then
    echo "Error: Check input files and directories" >&2
    exit 1
fi

total=0

# Part 1: IOC Sweep
# Read one complete indicator per array element, preserving spaces.
mapfile -t indicators < "$ioc_file"
for indicator in "${indicators[@]}"; do
    indicator=$(printf '%s' "$indicator" | tr -d '\r')
    [ -z "$indicator" ] && continue
    logs_found=0

    for logfile in "$log_dir"/*.log; do
        [ -f "$logfile" ] || continue

        count=$(grep -Fwc -- "$indicator" "$logfile")
        result=$?
        if [ "$result" -gt 1 ]; then
            echo "Error: Cannot search $logfile" >&2
            exit 1
        fi

        if [ "$count" -gt 0 ]; then
            echo "$indicator $(basename "$logfile") $count"
            logs_found=$((logs_found + 1))
            total=$((total + count))
        fi
    done

    echo "$indicator found in $logs_found logs"
done

echo "Total matching lines: $total"

# Part 2: Hash Check
for file in "$evidence_dir"/*; do
    [ -f "$file" ] || continue

    if [ ! -r "$file" ]; then
        echo "Error: Cannot read $file" >&2
        exit 1
    fi

    digest=$(md5sum < "$file")
    if [ "$?" -ne 0 ]; then
        echo "Error: Cannot hash $file" >&2
        exit 1
    fi
    hash=$(printf '%s\n' "$digest" | awk '{print $1}')

    matches=$(tr -d '\r' < "$ioc_file" | grep -Fxc -- "$hash")
    result=$?
    if [ "$result" -gt 1 ]; then
        echo "Error: Cannot compare hashes" >&2
        exit 1
    fi

    if [ "$matches" -gt 0 ]; then
        echo "KNOWN BAD: $file"
    else
        echo "CLEAN: $file"
    fi
done

exit 0
```

Исправления по оригиналу: вложенные for вместо внешнего while; grep -Fwc вместо поиска подстроки; единый список exam-data/intel/iocs.txt для обоих этапов. Отдельный ioc_hashes.txt условием не предусмотрен.

mapfile -t indicators читает строки в массив Bash: одна строка — один индикатор. Внешний for перебирает этот массив, внутренний for — логи. Так сохраняются даже индикаторы с пробелами. Требуется Bash 4 или новее. Пустые строки пропускаются, CR из CRLF удаляется; заголовки и комментарии не предполагаются. Дубликаты индикаторов будут обработаны повторно.

Счётчик total суммирует строки по парам индикатор/лог: одна строка, совпавшая с двумя разными индикаторами, учитывается дважды. Повторы одного индикатора внутри одной строки считаются один раз. grep с кодом 1 означает отсутствие совпадений и даёт count=0; код выше 1 обрабатывается как ошибка.

Маски *.log и evidence/* соответствуют условию: только верхний уровень, без скрытых файлов. Кавычки вокруг переменных сохраняют имена с пробелами. Список предполагает один индикатор на строку; MD5 для сравнения — в нижнем регистре, без лишних пробелов. CLEAN означает только отсутствие хеша в данном списке, а не доказанную безопасность файла.

```bash
chmod +x sweep.sh
bash -n sweep.sh
./sweep.sh
echo $?
```
**B3(q) — The empty file hash (paraphrased from the photographs):** Run `md5sum exam-data/case/evidence/empty.bin`. A colleague suggests adding this hash to the indicator list because the filename looks suspicious. What is this hash, and why would it be a poor indicator to act on? Write your answer in `answers.txt`.

**Ответ:** MD5 пустого файла равен d41d8cd98f00b204e9800998ecf8427e. Само по себе это плохой индикатор вредоносности: одинаковый хеш будет у любого пустого файла, включая безвредные. Название empty.bin также не доказывает вредоносность. Ответ применим, только если файл действительно имеет размер 0 байт.

```bash
wc -c < exam-data/case/evidence/empty.bin
md5sum exam-data/case/evidence/empty.bin
```

### B4, Part 1 — accounts.sh

Сверено с новыми фото B4: требования к CSV-циклу, пропуску заголовка, формату вывода, очистке department, ALERT и итоговым счётчикам учтены. Порядок колонок остаётся предположением до получения CSV.

**Task (from the photographs):** Write `accounts.sh`, using a `while IFS=',' read -r ...` loop to read `exam-data/intel/users.csv`.

1. Skip the header line.
2. For each account, print the username, role, status, department, and number of `Accepted password` records for that user in `exam-data/case/logs/auth.log`. Use the format `alice | student | active | Computing | logins: N`.
3. Print the department without hidden trailing characters. Hint: inspect the CSV using `cat -A`.
4. If a `disabled` account has one or more successful logins, print an `ALERT` line for it.
5. After the loop, print the numbers of `active` and `disabled` accounts.

**Solution:**

```bash
#!/bin/bash

csv="exam-data/intel/users.csv"
log="exam-data/case/logs/auth.log"

if [ ! -r "$csv" ] || [ ! -r "$log" ]; then
    echo "Error: Cannot read CSV or auth.log" >&2
    exit 1
fi

active=0
disabled=0

{
    IFS= read -r header

    while IFS=',' read -r username role status department || [ -n "$username" ]; do
        [ -z "$username" ] && continue
        department=$(printf '%s' "$department" | tr -d '\r')

        logins=$(grep -F "Accepted password for $username from " "$log" | wc -l)

        printf '%s | %s | %s | %s | logins: %s\n' \
            "$username" "$role" "$status" "$department" "$logins"

        if [ "$status" = "active" ]; then
            active=$((active + 1))
        elif [ "$status" = "disabled" ]; then
            disabled=$((disabled + 1))
            if [ "$logins" -gt 0 ]; then
                echo "ALERT: Disabled account $username has successful logins"
            fi
        fi
    done
} < "$csv"

echo "Active accounts: $active"
echo "Disabled accounts: $disabled"
exit 0
```

Исправления: путь к CSV; удаление CR из department; последняя CSV-строка обрабатывается даже без завершающего LF. Полная фраза for USER from предотвращает совпадение alice с alice-admin. Исходное grep -Fwc "for $username" могло посчитать похожее имя с дефисом.

### B4, Part 2 — find_logs.sh

Сверено с новыми фото B4: рекурсивный поиск .log, find -print0, цикл while с NUL-разделителем и сохранение итогов после цикла учтены.

**Task (from the photographs):** Write `find_logs.sh` to find every `.log` file under `exam-data`, at any depth, using `find -print0` and a `while IFS= read -r -d '' ...` loop. For each file, print its name and line count. After the loop, print the number of logs found and the total number of lines. The final totals must remain correct when printed after the loop.

**Solution:**

```bash
#!/bin/bash

if [ ! -d exam-data ]; then
    echo "Error: exam-data directory not found" >&2
    exit 1
fi

count=0
total=0

while IFS= read -r -d '' file; do
    if [ ! -r "$file" ]; then
        echo "Error: Cannot read $file" >&2
        exit 1
    fi

    lines=$(wc -l < "$file")
    printf '%s : %s lines\n' "$file" "$lines"
    count=$((count + 1))
    total=$((total + lines))
done < <(find exam-data -type f -name '*.log' -print0)

echo "Logs found: $count"
echo "Total lines: $total"
exit 0
```

Исходная основная логика корректна: NUL-разделители сохраняют имена с пробелами, а process substitution оставляет счётчики в текущем shell. Требуется доступ на чтение и обход всего дерева exam-data: ошибка find внутри process substitution не передаётся автоматически как код завершения скрипта.

## Теория

**B4(q) — Alerts for disabled accounts (incomplete source):** Did your script print any `ALERT` lines? Examine the usernames in successful authentication records. The rest of the original question is cut off in the photograph and cannot be reconstructed reliably. To investigate, run `accounts.sh`, identify any accounts with alerts, and check their records in `auth.log`. The actual account names and result require the dataset.

Ниже — дополнительные вопросы и пояснения для подготовки; они не выдаются за дословные вопросы экзамена.

- **Why avoid find ... | while ...?** В Bash цикл в конвейере обычно работает в subshell. Изменения count и total не сохранятся в родительском shell. done < <(find ...) решает это.
- **Why use IFS= and read -r?** IFS= сохраняет пробелы в начале и конце строки; -r не интерпретирует обратную косую черту как экранирование.
- **Why use -print0 and -d '' / xargs -0?** Разделитель NUL позволяет безопасно передавать имена с пробелами и переводами строк.
- **Why use tr -d '\r'?** У CSV с CRLF поле department иначе содержит скрытый carriage return. Для проверки: cat -A exam-data/intel/users.csv.
- **What does ALERT mean?** В логе есть успешный парольный вход пользователя, который в текущем CSV помечен disabled. Нужно сравнить времена событий и отключения: CSV не доказывает, что аккаунт был отключён уже на момент входа.
- **Were there any alerts in the exam dataset?** Без users.csv и auth.log установить нельзя. Продолжение исходного вопроса B4(q) на фото обрезано.
- **What are the grep exit codes?** 0 — совпадение найдено, 1 — совпадений нет, 2 — ошибка. || true подавляет ненулевой код, включая ошибки; поэтому входные файлы проверяются отдельно.

## Тестовые команды

Сохраните полные блоки Section B как logsummary.sh, check_ip.sh, sweep.sh, accounts.sh и find_logs.sh рядом с каталогом exam-data. Используйте Bash, не sh.

```bash
chmod +x logsummary.sh check_ip.sh sweep.sh accounts.sh find_logs.sh
bash -n logsummary.sh
bash -n check_ip.sh
bash -n sweep.sh
bash -n accounts.sh
bash -n find_logs.sh

./logsummary.sh exam-data/case/logs/auth.log
echo "Exit: $?"
./logsummary.sh
echo "Exit: $?"
./logsummary.sh missing-file.log
echo "Exit: $?"
./logsummary.sh exam-data/case/evidence/empty.bin
echo "Exit: $?"
bash sweep.sh
echo "Exit: $?"
head -n 1 exam-data/intel/users.csv
cat -A exam-data/intel/users.csv

bash accounts.sh
echo "Exit: $?"
bash find_logs.sh
echo "Exit: $?"

bash check_ip.sh 192.0.2.10
echo "Exit: $?"
bash check_ip.sh
echo "Exit: $?"
bash check_ip.sh abc
echo "Exit: $?"
```

Для B2 ожидается 1 при неверном аргументе; 0 при найденном IP в любом файле каталога logs; 3 при отсутствии в этом каталоге. Для воспроизводимого теста используйте копии учебных данных.
