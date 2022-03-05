# Ввод-вывод и исключения
## Плавный ввод в исключения

Давайте продолжим на чем мы остановились на предыдущей лекции — ``Scanner``. Представьте себе, что нам хочется прочитать файл. Если изучить [документацию](https://docs.oracle.com/javase/7/docs/api/java/util/Scanner.html), то можно узнать, что ``Scanner`` принимает ``java.io.File``:

```java
import java.util.Scanner;  
import java.io.File;  
  
public class IOExample {  
    public static void main(String[] args) {  
        Scanner sc = new Scanner(new File("input.txt"));  
        while (sc.hasNext()) {  
            System.out.print(sc.next() + " ");  
        }  
    }  
}
```
Компилируем программу, и... вылетает ошибка. Оказывается бывает **FileNotFoundException**, и он должен быть либо пойман, либо мы должны его пробросить. Странно. Мы уже сталкивались со всякими исключениями, вроде **NullPointerException**, **ArrayIndexOutOfBoundsException**, и ничего. А тут нас внезапно просят что-то сделать. Возникает вопрос --- а с чем это связано?

Связано это с простым соображением --- если вылетает **NullPointerException**, то чья вина? Программиста. А если **ArrayIndexOutOfBoundsException**? Тоже программиста. А вот если мы запускаем программу, и файла ``input.txt`` нет, то чья вина? Правильно, пользователя! Программист с этим ничего сделать не может.

 Так вот, Java разделяет исключения на два вида --- **проверяемые** и **непроверяемые** исключения. **FileNotFoundException** относится к проверяемым исключениям, поэтому мы в явной форме должны его обработать. К примеру вот так:
 ```java
 try {  
    Scanner sc = new Scanner(new File("input.txt"));  
    while (sc.hasNext()) {  
        System.out.print(sc.next() + " ");  
    }  
} catch (FileNotFoundException e) {  
    System.out.println("input file not found!");  
}
```
```java
input file not found!
```

Понятно, что если добавить файл ``input.txt``, то мы просто выведем все строки в этом файле. А что если запустить вот такой код?
 ```java
 try {  
    Scanner sc = new Scanner(new File("input.txt"));  
    while (sc.hasNext()) {  
        System.out.print(sc.nextInt() + " ");  
    }  
} catch (FileNotFoundException e) {  
    System.out.println("input file not found!");  
}
```

В таком случае мы рискуем словить **InputMismatchException**. Несмотря на то, что нас не заставляли его ловить, мы всё еще можем его поймать!
 ```java
 try {  
    Scanner sc = new Scanner(new File("input.txt"));  
    while (sc.hasNext()) {  
        System.out.print(sc.nextInt() + " ");  
    }  
} catch (InputMismatchException e) {  
    System.out.println("invalid input!");  
} catch (FileNotFoundException e) {  
    System.out.println("input file not found!");  
}
```

Теперь у нас код может бросать исключения! Раньше они просто вываливались наружу, а мы потом смотрим на их описание из StackTrace. При желании мы его можем поймать, и обработать тем способом, что нам нравится. Также можно пробросить проверяемое исключение --- мы можем в явной форме сказать, что наш ``main`` бросает **FileNotFoundException**. Тогда мы его можем не ловить, но компилятор проверит --- окэй, вы исключение не поймали, но ваш метод его может выбросить, поэтому код всё еще корректный!
```java
public static void main(String[] args) throws FileNotFoundException {  
    try {  
        Scanner sc = new Scanner(new File("input.txt"));  
        while (sc.hasNext()) {  
            System.out.print(sc.nextInt() + " ");  
        }  
    } catch (InputMismatchException e) {  
        System.out.println("invalid input!");  
    }  
}
```
В принципе, разница в Java между проверяемыми и непроверяемыми исключениями заключается в том, что компилятор заставит нас в явной форме проверить, если исключение можно проверить. Либо нужно написать ``try-catch``, либо указать, что метод может бросать проверяемое исключение.

Для непроверяемых исключений эти правила не действуют. Давайте подумаем, много ли мы можем написать кода, который не бросает **NullPointerException**? Это значит, что мы не можем вызвать ни один метод ни на одном объекте. Заставлять вокруг каждой операции писать **try-catch** было бы странно.

## 100 фактов об исключениях

У исключений есть сообщение, и его имеет смысл выводить пользователю:
```java
try {  
    Scanner sc = new Scanner(new File("input.txt"));  
    while (sc.hasNext()) {  
        System.out.print(sc.next() + " ");  
    }  
} catch (FileNotFoundException e) {  
    System.out.println("invalid input: " + e.getMessage());  
}
```
```java
invalid input: input.txt (Не удается найти указанный файл)
```

Если нам хочется отладку, то мы всегда можем попросить StackTrace:
```java
try {  
    Scanner sc = new Scanner(new File("input.txt"));  
    while (sc.hasNext()) {  
        System.out.print(sc.next() + " ");  
    }  
} catch (FileNotFoundException e) {  
    e.printStackTrace();  
}
```
```java
java.io.FileNotFoundException: input.txt (Не удается найти указанный файл)
	at java.base/java.io.FileInputStream.open0(Native Method)
	at java.base/java.io.FileInputStream.open(FileInputStream.java:212)
	at java.base/java.io.FileInputStream.<init>(FileInputStream.java:154)
	at java.base/java.util.Scanner.<init>(Scanner.java:639)
	at IOExample.main(IOExample.java:8)
```

Нам честно напишут StackTrace ровно в той форме, как если бы мы его выбросили наружу. В основном это используется чтобы писать StackTrace в логи. Мы исключение не выбросили, а обработали и руками написали StackTrace. В реальности Java при запуске вызывает метод ``main`` в ``try-catch`` для всех исключений, и для пойманного исключения пишется StackTrace.

> Вопрос --- нужно ли обрабатывать **InputMismatchException** от сканнера? Чья ответственность в том, что мы ожидали число, а там по факту не число?

> Это зависит --- либо могли мы написать неправильный кривой код, либо пользователь мог сам нарушить соглашение из документации. Нет однозначного ответа. Оно непроверяемое, поэтому Java не заставляет нас его ловить, однако если вы уверены, что оно вызовется, то лучше его поймать.


Вопрос --- имеет ли смысл когда бы либо пробрасывать исключения? Мы сгенерировали исключения, и тут же их обработали! Понятно, что есть смысл. Вот пример:

```java
private Scanner scanFile(String filename) {  
    return new Scanner(new File(filename));  
}
```
Этот код не скомпилируется потому, что, с одной стороны конструктор сканнера бросает исключение, а с другой стороны ``scanFile`` его не обрабатывает и не пробрасывает. В таком случае, можем ли мы его обработать в ``scanFile``?
```java
private static Scanner scanFile(String filename) {  
    try {  
        return new Scanner(new File(filename));  
    } catch (FileNotFoundException e) {  
        System.out.println("File not found!");  
        return null;  
    }  
}  
public static void main(String[] args) throws FileNotFoundException {  
    try {  
        Scanner sc = scanFile("input.txt");  
        while (sc.hasNext()) {  
            System.out.print(sc.next() + " ");  
        }  
    } catch (InputMismatchException e) {  
        System.out.println("invalid input!");  
    }  
}
```

Хм, но это породит **NullPointerException**, так как ``scanFile`` вернул ``null``. И что делать? Писать так?
```java
public static void main(String[] args) throws FileNotFoundException {  
    try {  
        Scanner sc = scanFile("input.txt");
        if (in != null) {
	    while (sc.hasNext()) {  
		System.out.print(sc.next() + " ");  
            }  
        }
    } catch (InputMismatchException e) {  
        System.out.println("invalid input!");  
    }  
}
```
Это же неудобно! Собственно говоря, это является идиоматическим примером, когда стоит пробросить исключение. Не надо его пытаться здесь обрабатывать, мы *не знаем*, что с ним делать. Ну вот не удалось открыть файл на чтение. Нужно либо сообщить пользователю, что не удалось открыть, либо проигнорировать. В любом случае, в методе ``scanFile`` недостаточно информации для обработки этого исключения, поэтому честно напишем, что метод пробрасывает исключение.
```java
private static Scanner scanFile(String filename) throws FileNotFoundException {  
    return new Scanner(new File(filename)); 
}  
```
Тогда, разумеется, Java будет знать, что ``scanFile`` бросает исключение, тогда она заставит нас вернуть ``try-catch`` блок. Тут важно, что мы его будем обрабатывать ровно в том месте, когда мы знаем, что конкретно значит это исключение.

Итого --- неверно утверждение, что нужно всегда обрабатывать исключение в том же методе, где оно образовалось. Нет, есть куча методов, где более-чем логично пробрасывать исключение выше.


Хорошо, теперь давайте представим, что мы хотим записать что-то в ``input.txt``. Сможем ли мы это сделать? На самом деле, это зависит много от чего. В чем проблема? У нас есть ``Scanner``, который читает файл ``input.txt``. Вопрос, можно ли записать в файл, открытый на чтение, зависит много от чего, и чаще всего ответ --- нет. 

Тогда вопрос --- когда ``Scanner`` отпустит файл? Для этого у ``Scanner`` есть метод ``close()``, позволяющий нам явно отпустить файл. 

```java
private static Scanner scanFile(String filename) throws FileNotFoundException {  
    return new Scanner(new File(filename));  
}  
public static void main(String[] args) {  
    try {  
        Scanner sc = scanFile("input.txt");  
        while (sc.hasNextInt()) {  
            System.out.print(sc.nextInt() + " ");  
        }  
        sc.close();  
    } catch (InputMismatchException e) {  
        System.out.println("invalid input!");  
    } catch (FileNotFoundException e) {  
        System.out.println("invalid input!");  
    }  
}
```

Отлично компилируется, метод ``close()`` не бросает исключения и освобождает ресурсы ``input.txt``. Правда ли, что мы точно теперь всегда сможем в ``input.txt`` записать? На самом деле нет. Если мы словим **FileNotFoundException**, то всё хорошо, так как сканнер не существовал и в природе. А вот если случился **InputMismatchException**, то возникают проблемы, потому что нужно не забыть закрыть сканнер! Теперь всё хорошо?
```java
try {  
    Scanner sc = scanFile("input.txt");  
    while (sc.hasNextInt()) {  
        System.out.print(sc.nextInt() + " ");  
    }  
    sc.close();  
} catch (InputMismatchException e) {  
    System.out.println("invalid input!");  
    sc.close();  
} catch (FileNotFoundException e) {  
    System.out.println("invalid input!");  
}
```
Нет. У нас нет ``sc``, так как он определен в блоке ``try``, а переменные из разных блоков не видят друг друга! Хорошо, а вот так?
```java
Scanner sc;  
try {  
    sc = scanFile("input.txt"); // <-- мисматч может тут возникнуть
    while (sc.hasNextInt()) {  
        System.out.print(sc.nextInt() + " ");  
    }  
    sc.close();  
} catch (InputMismatchException e) {  
    System.out.println("invalid input!");  
    sc.close();  // <-- вот тут ошибка
} catch (FileNotFoundException e) {  
    System.out.println("invalid input!");  
}
```
Опять нет. Компилятор говорит, что ``sc``  может быть даже не проинициализирован! С нашей точки понятно, что **InputMismatchException** не может произойти до того как мы открыли сканнер, но с точки зрения Java --- это непроверяемое исключение, и оно может возникнуть где угодно. Давайте еще раз попытаемся исправить:

```java
Scanner sc = null;  
try {  
    sc = scanFile("input.txt");  
    while (sc.hasNextInt()) {  
        System.out.print(sc.nextInt() + " ");  
    }  
    sc.close();  
} catch (InputMismatchException e) {  
    System.out.println("invalid input!");  
    if (sc != null) {  
        sc.close();  
    }  
} catch (FileNotFoundException e) {  
    System.out.println("invalid input!");  
}
```
Ура, оно скомпилировалось! Значит ли это, что мы смогли защитить себя со всех сторон? Спойлер, нет. Если произошел **FileNotFoundException**, то закрывать нечего. Замечательно. Если произошел **InputMismatchException**, то мы проверили и закрыли, все хорошо. Но мало ли тут еще исключений может выскочить! Тогда мы не закроем наш сканнер. Что же делать? Нам нужно сделать какое-то действие вне зависимости от того произошло какое-то исключение или нет. 

Это совершенно типичная ситуация, для решения которой есть ``finally`` блок:
```java
try {  
    Scanner sc = scanFile("input.txt");  
    try {  
        while (sc.hasNextInt()) {  
            System.out.print(sc.nextInt() + " ");  
        }  
    } finally {  
        sc.close();  
    }  
} catch (InputMismatchException e) {  
    System.out.println("invalid input!");  
} catch (FileNotFoundException e) {  
    System.out.println("invalid input!");  
}
```
Какова логика работы ``finally`` блока? Вы пошли в ``try`` блок, и вне зависимости от того, как закончился ``try`` блок, соответствующий ``finally`` блок будет выполнен. В целом это стандартная идиома --- взять ресурс, открыть его, поработать с ним, и не забыть в ``finally`` блоке его закрыть. Если это не сделать, то это приводит к, так называемым, утечкам ресурсов.

Заметим, гарантирует ли нам Java, что если не вызвать ``.close()``, что файл будет открыт на чтение? Нет, не гарантирует, так как мы потеряли ссылку на ``Scanner``, и в любой момент может придти сборщик мусора и собрать ее, и это автоматически закроет вашу память. Проблема в том, что мы не можем предсказать когда это произойдет. То есть ресурсы утекли, через некоторое время они могут освободиться, а если у вас много памяти, и вы её всю не используете, то может никогда не освободятся.

Теперь дальше. В целом в нашу конструкцию ``try-finally`` можно вписать произвольное количество блоков ``catch``. Если код внутри ``try`` не бросил исключение, то все ``catch`` блоки игнорируются, и выполняется ``finally`` блок. Если код бросил исключение, и оно поймано одним из ``catch`` блоков, то после его обработки выполнится ``finally`` блок. Если ни один из ``catch`` блоков не поймал исключение, то его пробросят дальше, однако ``finally`` блок всё равно будет исполнен.

```java
try {  
    Scanner sc = scanFile("input.txt");  
    try {  
        while (sc.hasNextInt()) {  
            System.out.print(sc.nextInt() + " ");  
        }  
    } catch (InputMismatchException e) {  
        System.out.println("invalid input!");  
    } finally {  
        sc.close();  
    }  
} catch (FileNotFoundException e) {  
    System.out.println("invalid input!");  
}
``` 

Теперь вопрос на понимание --- можно ли ``catch`` блок с **FileNotFoundException** перенести вверх рядом с **InputMismatchException**? Нет, так **InputMismatchException** умеет вылетать только из внутреннего блока, а **FileNotFoundException** вылетает только из внешнего блока.

Типичная конструкция для работы с ресурсами.

Теперь вопрос про людей, пробовавших считать с помощью ``Scanner`` миллион чисел. Работает медленно, правда? Дело в том, что сам ``Scanner`` реализован на регулярных выражениях, и он ими постоянно пытается понять -- число, или не число.  Понятно, что в лабах и реальной жизни нам придётся считывать много чисел, поэтому мы научимся, как это делать быстро!



Давайте познакомимся с классом ``FileReader``. Как следует из названия, он читает из файла. Тут же его закроем, чтобы не забыть позднее. 

 ```java
 FileReader reader = new FileReader("java-test/input.txt");  
try {  
    System.out.println(reader.read());;  
} finally {  
    reader.close();  
}
```

Данный код не скомпилируется, и вылетит с ошибкой. Даже не одной, а тремя! Во первых **FileNotFoundException** при попытке считать с файла, и бывает **IOException** при закрытии и попытке чтения. Давайте попытаемся их обработать, однако нужно быть внимательными, так как **FileNotFoundException** является **IOException**, и мы можем прострелить себе ногу, если будем ловить их не в том порядке. Но в нашем случае, это работает нам на руку.

```
[input.txt]
hello
```
```java
try {  
    FileReader reader = new FileReader("java-test/input.txt");  
    try {  
        System.out.println(reader.read());  
    } finally {  
        reader.close();  
    }  
} catch (IOException e) {  
    System.out.println("IO ERROR: " + e.getMessage());  
}
```
```java
104
```

Должно вызывать недоумение. Программа сработала корректно, однако вместо ``hello`` мы получили 104. На самом деле всё хорошо, просто ``reader.read()`` читает один символ, и возвращает ``int``. 

```java
try {  
    FileReader reader = new FileReader("java-test/input.txt");  
    try {  
        System.out.println((char) reader.read());  
    } finally {  
        reader.close();  
    }  
} catch (IOException e) {  
    System.out.println("IO ERROR: " + e.getMessage());  
}
```
```java
h
```

Давайте попытаемся прочитать весь ввод. Однако мы упремся в стандартную проблему --- как понять что мы прочитали весь файл? Логика такая --- когда ``.read()`` достиг конца, он возвращает -1. Именно поэтому, он возвращает ``int``, а не ``char``. Вот так прочитать весь ввод:
```java
while (true) {  
    int input = reader.read();  
    if (input == -1) break;  
    System.out.println((char) input);  
}
```

Однако польза от символов по одному довольно сомнительна, поэтому давайте сделаем строку:
```java
String s = "";  
while (true) {  
    int input = reader.read();  
    if (input == -1) break;  
    s += (char) input;  
}  
System.out.println(s);
```
Однако это имеет свою проблему. Давайте вспомним, что строчки в Java не изменяются, поэтому это работает за квадрат. Фактически мы копируем всю предыдущую часть строки и только потом добавлять. Но как тогда получить строчку? На помощь нам приходит замечательный класс ``StringBuilder``, у которого есть метод ``.append(char)``. Это гарантированно работает за линейное время, в отличии от складывания строк в цикле:
```java
StringBuilder s = new StringBuilder();  
while (true) {  
    int input = reader.read();  
    if (input == -1) break;  
    s.append((char) input);  
}  
System.out.println(s.toString());
```
**Пожалуйста никогда не складывайте строки в цикле**.

Итого, мы производим чтение посимвольно, но для каждого символы мы обращаемся в операционную систему, и просим этот символ. Всё еще не очень быстро. Два варианта решения проблемы.

Первый вариант --- обернуть наш ``FileReader`` в ``BufferedReader``. Из названия уже можно догадаться, что мы сделали. Он буфферизирует наши входные данные. Всё продолжает работать, только теперь, скорее всего быстрее. При необходимости можно указать ``BufferedReader`` размер буффера, но если не уверены лучше использовать значение по умолчанию.

```java
try {  
    Reader reader = new BufferedReader(  
            new FileReader("java-test/input.txt")  
    );  
    try {  
        StringBuilder s = new StringBuilder(); 
        while (true) {  
            int input = reader.read();  
            if (input == -1) break;  
            s.append((char) input);  
        }  
        System.out.println(s.toString());  
  
    } finally {  
        reader.close();  
    }  
} catch (IOException e) {  
    System.out.println("IO ERROR: " + e.getMessage());  
}
```

Второй вариант --- мы всё равно для каждого символа вызываем по методу. Тоже не очень быстро. Однако ``Reader`` поддерживает блочный ввод.
```
[input.txt]
hello itmo
```
```java
try {  
    Reader reader = new BufferedReader(  
            new FileReader("java-test/input.txt")  
    );  
    try {  
        StringBuilder s = new StringBuilder();  
        char[] buffer = new char[3];  
        while (true) {  
            int input = reader.read(buffer);  
            if (input == -1) break;  
            s.append(buffer);  
        }  
        System.out.println(s.toString());  
  
    } finally {  
        reader.close();  
    }  
} catch (IOException e) {  
    System.out.println("IO ERROR: " + e.getMessage());  
}
```
```java
hello itmotm
```

Как написано в [документации](https://docs.oracle.com/javase/7/docs/api/java/io/BufferedReader.html), в ``BufferedReader`` нужно оборачивать ``Reader``, у которого метод ``.read()`` дорог по времени. Также можно считать по несколько символов сразу, что мы и делаем с помощью массива `buffer`. Метод ``.read(char[])`` у ``BufferedReader`` возвращает количество считанных символов, или -1, если всё уже считали.

Однако возникает вопрос --- у нас в ``input.txt`` слово ``hello itmo``, а программа выводит какое-то ``hello itmotm``! Дело в том, что перед очередным чтением в ``buffer``, мы сам ``buffer`` не очищаем, а метод  ``.read(char[])`` пытается запихать в ``buffer`` только сколько он может, и если у нас на очередной итерации символов в файле останется меньше, чем размер ``buffer``, то он запишет только их, и не станет трогать остальные.

```java
StringBuilder s = new StringBuilder();  
char[] buffer = new char[3];  
while (true) {  
    int read = reader.read(buffer);  
    if (read < 0) break;  
    s.append(new String(buffer, 0, read));  
}  
System.out.println(s.toString());
```
```
hello itmo
```

Вот так лучше. Конечно, в реальной жизни размер ``buffer`` будет не 3, а что-то вроде 1024. Кстати, никто не гарантирует, что если ``read`` вернул символов меньше, чем длина буффера, то файл закончился. Формально, контракт метода ``.read(char[])`` гарантирует, что вернёт столько символов, сколько может прямо сейчас, если прочитал хотя бы один, ну или будет ждать, пока появится что-то новое. Если эти символы не из файла, или этот файл находится где-то по сети, и целиком не доступен, то нам могут выдавать кусочками того размера, которого поступают данные. Именно поэтому, данные закончились, только тогда, когда нам вернули -1.

Итого --- блочный ввод, отличным образом работает, но нужно не забывать, сколько мы символов прочли, и аккуратно это использовать. По времени, конечно, блочный ввод работает быстрее, чем пассивный. Кстати, одновременно читать блоками из ``BufferedReader`` не очень полезно. То есть ``BufferedReader`` будет пытаться буфферизировать, но у него ничего не выйдет, так как мы сами читаем блоком. Но если блоки маленькие, то это будет работать.

50:46
