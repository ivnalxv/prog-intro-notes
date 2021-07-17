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

Вопрос --- нужно ли обрабатывать **InputMismatchException** от сканнера? Чья ответственность в том, что мы ожидали число, а там по факту не число?

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
Спойлер, оно скомпилируется. Правда ли это, что мы смогли защитить себя со всех сторон?
