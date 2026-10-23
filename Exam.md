# Scripting Exam 

## Источники и границы проверки

Собраны Section A A1–A8, полные скрипты B1–B3 и оба скрипта B4, теоретические пояснения и команды проверки. Проведена проверка кода по доступным условиям и оговорённым предположениям. Полного текста условий B1–B3 нет, поэтому соответствие всем требованиям преподавателя не подтверждено.

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

### B1 — Log file summary

**Task — reconstructed from the supplied script; the original exam wording is unavailable:** Write a Bash script that accepts exactly one file path. Exit with code 1 if the number of arguments is incorrect, 2 if the path is not a regular file, and 3 if the file is empty. For a non-empty file, print its path, line count, counts of `Failed password` and `Accepted password` records, and the first three fields of the first and last lines. Exit with code 0 on success. The readability check, which returns code 2, is an addition in this solution.

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

Основная логика присланного решения корректна. Добавлена проверка чтения; grep -Fc ищет буквальный текст. Перенаправление входа позволяет обработать имя, начинающееся с дефиса. Сохранены коды: 1 — неверное число аргументов, 2 — нет обычного файла или его нельзя прочитать, 3 — пустой файл, 0 — успех. Код 2 для ошибки чтения — принятое здесь дополнение, поскольку полного условия B1 нет.

Предполагается syslog-формат, где первые три поля — месяц, день и время. First и Last показывают первую и последнюю запись в порядке файла, а не вычисленные минимальную и максимальную даты. Для ISO-формата или записей с hostname в первых трёх полях эту часть нужно адаптировать. wc -l считает переводы строк: предполагается LF в конце каждой записи. Подсчёт событий корректен при одной записи на строку. Автоматический запуск не подтверждён из-за ранее описанной ошибки Bash.


### B2 — IP address risk report

**Task — reconstructed from the supplied script; the original exam wording is unavailable:** Write a Bash script that accepts one IPv4 address. Count its `Failed password` and `Accepted password` records in `exam-data/case/logs/auth.log`, check whether it appears in `exam-data/case/evidence/watchlist.txt`, and print a report.

- Assign risk based on the number of failures: 0 — `NONE`, 1–4 — `LOW`, 5–9 — `MEDIUM`, 10 or more — `HIGH`.
- Print a warning if both failed and successful logins are present. This solution does not check their chronological order.
- Return 0 if the address appears in either the log or the watchlist, 3 if it appears in neither, and 1 for invalid arguments.
- Validation of each address component against the range 0–255 and input readability checks are additions in this solution. Input read errors return 1.

**Solution:**

Полный скрипт B2.sh с упрощённым подсчётом:

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
    # Each part must contain one to three digits.
    case "$part" in
        ''|*[!0-9]*)
            echo "Error: Provide one IPv4 address" >&2
            exit 1
            ;;
    esac

    if [ "${#part}" -gt 3 ]; then
        echo "Error: Provide one IPv4 address" >&2
        exit 1
    fi

    # 10# makes Bash read the number as decimal, including 08 or 09.
    if [ "$((10#$part))" -gt 255 ]; then
        echo "Error: Provide one IPv4 address" >&2
        exit 1
    fi
done

log="exam-data/case/logs/auth.log"
watchlist="exam-data/case/evidence/watchlist.txt"

if [ ! -r "$log" ] || [ ! -r "$watchlist" ]; then
    echo "Error: Cannot read auth.log or watchlist.txt" >&2
    exit 1
fi

failed=$(grep -F "Failed password" "$log" | grep -Fwc "$ip" || true)
accepted=$(grep -F "Accepted password" "$log" | grep -Fwc "$ip" || true)

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
    listed="YES"
else
    listed="NO"
fi

echo "IP       : $ip"
echo "Failed   : $failed"
echo "Accepted : $accepted"
echo "Risk     : $risk"
echo "Watchlist: $listed"

if [ "$failed" -gt 0 ] && [ "$accepted" -gt 0 ]; then
    echo "WARNING: both failed and successful logins found"
fi

if grep -Fwq "$ip" "$log" || grep -Fxq "$ip" "$watchlist"; then
    exit 0
else
    exit 3
fi
```

Ключевые строки подсчёта:

```bash
failed=$(grep -F 'Failed password' "$log" | grep -Fwc "$ip" || true)
accepted=$(grep -F 'Accepted password' "$log" | grep -Fwc "$ip" || true)
```

Важные результаты проверки остальной логики:

- Границы NONE=0, LOW=1–4, MEDIUM=5–9, HIGH>=10 реализованы последовательно; соответствие именно условию B2 нельзя подтвердить без его текста.
- grep -Fxq корректен для watchlist с одним IP на строку, без пробелов и CRLF.
- grep -w проверяет границы слова, а точка не является символом слова. Поэтому grep -Fwc "$ip" не гарантирует строгое совпадение целого адреса для произвольного текста. Для стандартного SSH-лога с IP, отделёнными пробелами, учебный вариант подходит. Более точный простой вариант ниже.
- Наличие и отказов, и успешных входов не доказывает, что вход произошёл ПОСЛЕ отказов. Предупреждение исправлено, чтобы не заявлять непроверенную последовательность.
- Добавлены проверки чтения файлов, чтобы отсутствие входных данных не выглядело как нулевые счётчики.

Для точного подсчёта адреса источника можно сначала выделить поле после from, затем сравнить строку целиком:

```bash
failed=$(grep -F 'Failed password' "$log" | awk '{for(i=1;i<NF;i++) if($i=="from") {print $(i+1); break}}' | grep -Fxc "$ip" || true)
```

### B3 — IOC Sweep and Hash Check

**Task — partially reconstructed from the supplied script.** The photographs show the end of Part 1 and the requirements for Part 2; the beginning of Part 1 is unavailable.

**Part 1 — IOC Sweep (from the script and the visible requirements):** Read indicators from `exam-data/case/evidence/iocs.txt`. Search the `.log` files in `exam-data/case/logs` for each indicator. For each matching log, print the indicator, log filename, and matching line count. After each indicator, print how many logs contain it. Finally, print the total number of matching lines across all indicator/log pairs. An indicator with no matches must produce correct zero counts without errors. Substring matching and searching only the top directory level are assumptions of this solution, not confirmed requirements of the original task.

**Part 2 — Hash Check (from the photographs):** Use a `for` loop over `exam-data/case/evidence/*` to calculate the MD5 hash of every regular file. Print `KNOWN BAD: <file>` if the hash appears as a complete line in the hash list; otherwise, print `CLEAN: <file>`. Your script must work correctly when a filename contains spaces. The path `exam-data/case/evidence/ioc_hashes.txt` comes from the supplied script and must be checked against the actual dataset.

**Solution:**

```bash
#!/bin/bash

ioc_file="exam-data/case/evidence/iocs.txt"
log_dir="exam-data/case/logs"
evidence_dir="exam-data/case/evidence"
hash_file="exam-data/case/evidence/ioc_hashes.txt"

if [ ! -f "$ioc_file" ] || [ ! -r "$ioc_file" ] ||
   [ ! -f "$hash_file" ] || [ ! -r "$hash_file" ] ||
   [ ! -d "$log_dir" ] || [ ! -d "$evidence_dir" ]; then
    echo "Error: Check input files and directories" >&2
    exit 1
fi

total=0

# Part 1: IOC Sweep
while IFS= read -r indicator || [ -n "$indicator" ]; do
    indicator=$(printf '%s' "$indicator" | tr -d '\r')
    [ -z "$indicator" ] && continue
    logs_found=0

    for logfile in "$log_dir"/*.log; do
        [ -f "$logfile" ] || continue

        count=$(grep -Fc -- "$indicator" "$logfile")
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
done < "$ioc_file"

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

    matches=$(tr -d '\r' < "$hash_file" | grep -Fxc -- "$hash")
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

Проверка и исправления:

- Для общего поиска IOC использован grep -Fc: индикатор ищется как буквальная подстрока. Исходный -w мог пропустить индикатор внутри другого текста. Если условие требует именно отдельное слово, следует вернуть grep -Fwc. Полного условия Part 1 нет, поэтому поиск подстроки — явное предположение.
- Один IOC на строку, без заголовка и комментариев. Пустые строки пропускаются; CRLF и последняя строка без LF поддерживаются. Дубли индикаторов считаются повторно.
- Ищутся только *.log непосредственно в log_dir. Рекурсивность не предполагается. Отсутствие логов и отсутствие совпадений дают нулевые счётчики.
- Total — сумма совпавших строк по парам индикатор/лог. Одна строка с двумя разными IOC учитывается дважды. Повтор одного IOC в строке считается один раз.
- Ошибка grep теперь прерывает скрипт, вместо превращения её в результат без совпадений через || true.
- Хеши: один MD5 в нижнем регистре на строку, без имён файлов и пробелов. CRLF удаляется перед сравнением. md5sum получает файл через stdin, поэтому пробелы и обратные косые черты в имени не искажают извлечение хеша.
- Цикл evidence_dir/* соответствует видимому на фото требованию for по этой маске: только файлы верхнего уровня, без скрытых. Сами iocs.txt и ioc_hashes.txt также проверяются, если лежат там.
- CLEAN оставлено как требуемая метка. Оно означает только отсутствие хеша в данном списке и не доказывает безопасность файла.


**B3(q) — The empty file hash (paraphrased from the photographs):** Run `md5sum exam-data/case/evidence/empty.bin`. A colleague suggests adding this hash to the indicator list because the filename looks suspicious. What is this hash, and why would it be a poor indicator to act on? Write your answer in `answers.txt`.

**Ответ:** MD5 пустого файла равен d41d8cd98f00b204e9800998ecf8427e. Само по себе это плохой индикатор вредоносности: одинаковый хеш будет у любого пустого файла, включая безвредные. Название empty.bin также не доказывает вредоносность. Ответ применим, только если файл действительно имеет размер 0 байт.

```bash
wc -c < exam-data/case/evidence/empty.bin
md5sum exam-data/case/evidence/empty.bin
```

### B4, Part 1 — accounts.sh

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

Сохраните полные блоки Section B как B1.sh, B2.sh, B3.sh, accounts.sh и find_logs.sh рядом с каталогом exam-data. Используйте Bash, не sh.

```bash
bash -n B1.sh
bash -n B2.sh
bash -n B3.sh
bash -n accounts.sh
bash -n find_logs.sh

bash B1.sh exam-data/case/logs/auth.log
echo "Exit: $?"
bash B1.sh
echo "Exit: $?"
bash B1.sh missing-file.log
echo "Exit: $?"
empty_test=$(mktemp)
bash B1.sh "$empty_test"
echo "Exit: $?"
rm -- "$empty_test"
bash B3.sh
echo "Exit: $?"
head -n 1 exam-data/intel/users.csv
cat -A exam-data/intel/users.csv

bash accounts.sh
echo "Exit: $?"
bash find_logs.sh
echo "Exit: $?"

bash B2.sh 192.0.2.10
echo "Exit: $?"
bash B2.sh
echo "Exit: $?"
bash B2.sh 999.1.1.1
echo "Exit: $?"
```

Для B2 ожидается 1 при неверном аргументе; 0 при найденном IP в логе или watchlist; 3 при отсутствии в обоих. Для воспроизводимого теста используйте копии учебных данных.

Проведена проверка кода по тексту и условиям на фото. Автоматический запуск не состоялся: установленный Git Bash завершился с Windows-ошибкой доступа ещё до выполнения скриптов. Поэтому успешное прохождение синтаксических и функциональных тестов не подтверждено. Оригинальное exam-data также не предоставлено.
