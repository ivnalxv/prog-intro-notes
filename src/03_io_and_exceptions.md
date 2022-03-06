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

 Так вот, Java разделяет исключения на два вида --- **проверяемые** и **непроверяемые** исключения. **FileNotFoundException** относится к проверяемым исключениям, поэтому мы в явной форме должны его обработать.

Именно для этого существует такая конструкция, как ``try { ... } catch (...) { ... } ``.

К примеру вот так:
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

В таком случае мы рискуем словить **InputMismatchException**. Оно непроверяемое, а значит нас не заставляют его ловить, однако мы всё еще можем его поймать!

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

Теперь нам код может бросать исключения! Раньше, мы привыкли к тому, что они просто вываливались наружу, а мы потом смотрели на их описание из StackTrace. При желании мы исключение можем поймать, и обработать тем способом, что нам нравится. 

Также можно пробросить проверяемое исключение --- мы можем в явной форме сказать, что наш ``main`` бросает **FileNotFoundException**. Тогда мы его можем не ловить, но компилятор проверит --- окэй, вы исключение не поймали, но вы объявили, что ваш метод его может выбросить, поэтому код всё еще корректный!

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

Для непроверяемых исключений эти правила не действуют. 

Давайте подумаем, много ли мы можем написать кода, который не бросает **NullPointerException**? Это значит, что мы не можем вызвать ни один метод ни на одном объекте. Заставлять вокруг каждой операции писать **try-catch** было бы странно.

## 100 фактов об исключениях


### Сообщения
Далее. У исключений есть всякие полезные вещи: например у каждого исключения есть сообщение, и его имеет смысл выводить пользователю:
```java
try {  
    Scanner sc = new Scanner(new File("input.txt"));  
    while (sc.hasNext()) {  
        System.out.print(sc.next() + " ");  
    }  
} catch (InputMismatchException e) {  
	  System.out.println("invalid input: " + e.getMessage());  
} catch (FileNotFoundException e) {  
    System.out.println("file not found: " + e.getMessage());  
}
```
```java
file not found: input.txt (Не удается найти указанный файл)
```
Это та информация, что имеет смысл показывать пользователю.

<br/>

### Stack Trace

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

Нам честно напишут StackTrace ровно в той форме, как если бы мы его выбросили наружу. Понятно, что в основном это используется чтобы писать StackTrace в логи. 

То есть, мы исключение не выбросили, а обработали и руками написали StackTrace. В реальности Java при запуске вызывает метод ``main`` в ``try-catch`` для всех исключений, и для пойманного исключения пишется StackTrace. Магии нет, с тем же успехом можно сделать в своем коде руками.

<br/>

### Ответственность

> Вопрос --- нужно ли обрабатывать **InputMismatchException** от сканнера? Чья ответственность в том, что мы ожидали число, а там по факту не число?

Это зависит --- либо могли мы написать неправильный кривой код изначально, либо мы могли учесть всё, но пользователь сам нарушил соглашение из документации, подав нам не тот объект. Нет однозначного ответа.

Оно непроверяемое, поэтому Java не заставляет нас его ловить, однако если вы уверены, что оно вызовется, то лучше его поймать.

<br/>

### А зачем вообще?

> Вопрос --- вообще имеет ли смысл когда бы либо пробрасывать исключения? Мы сгенерировали исключения, и тут же их обработали! 

Понятно, что есть смысл. Вот пример:
```java
private Scanner scanFile(String filename) {  
	return new Scanner(new File(filename));  
}

public static void main(String[] args) {  
	try {  
		Scanner sc = scanFile("input.txt");  
		while (sc.hasNextInt()) {  
			System.out.print(sc.nextInt() + " ");  
		}  
	} catch (InputMismatchException e) {  
		System.out.println("invalid input: " + e.getMessage());  
	} catch (FileNotFoundException e) {  
		System.out.println("file not found: " + e.getMessage());  
	}
}
```

Скомпилируется ли? 

Нет, потому что с одной стороны конструктор сканнера бросает исключение, а с другой стороны ``scanFile`` его не обрабатывает и не пробрасывает. 

В таком случае, можем ли мы его в ``scanFile`` как то обработать? Смогли создать сканнер, то вернули, не смогли, то просто сказали, что мол ну не получилось. 

Попробуем:

```java
private static Scanner scanFile(String filename) {
	try {
		return new Scanner(new File(filename));
	} catch (FileNotFoundException e) {
		System.out.println("file not found: " + e.getMessage());
	}
}

public static void main(String[] args) {  
	try {  
		Scanner sc = scanFile("input.txt");  
		while (sc.hasNextInt()) {  
			System.out.print(sc.nextInt() + " ");  
		}  
	} catch (InputMismatchException e) {  
		System.out.println("invalid input: " + e.getMessage());  
	} catch (FileNotFoundException e) {
		System.out.println("file not found: " + e.getMessage());
	}
}
```
Компилятор сказал две вещи. 

Первое, что наша функция ничего не вернула. Действительно, когда создание сканнера бросило исключение, то мы ничего не возвращаем и идем в ``catch``-блок, после исполнения которого мы просто продолжаем исполнять код, и действительно ничего не возвращаем. Java проверяет, что если вы обещали что-то вернуть, то надо собственно вернуть.

Давайте вернём ``null``. Это конечно успокоит компилятор.

Теперь ошибка номер два. Говорят, что ``catch (FileNotFoundException e)`` ничего не поймает. Давайте уберем:
```java
private static Scanner scanFile(String filename) {
	try {
		return new Scanner(new File(filename));
	} catch (FileNotFoundException e) {
		System.out.println("file not found: " + e.getMessage());
		return null;
	}
}

public static void main(String[] args) {  
	try {  
		Scanner sc = scanFile("input.txt");  
		while (sc.hasNextInt()) {  
			System.out.print(sc.nextInt() + " ");  
		}  
	} catch (InputMismatchException e) {  
		System.out.println("invalid input: " + e.getMessage());  
	}
}
```
<br/>

Ой-ой, это породит **NullPointerException**, так как ``scanFile`` вернул ``null``. И что делать? Писать так?


```java
public static void main(String[] args) {  
	try {  
		Scanner sc = scanFile("input.txt"); 
		if (sc != null) {
			while (sc.hasNextInt()) {  
				System.out.print(sc.nextInt() + " ");  
			}
		}
	} catch (InputMismatchException e) {  
		System.out.println("invalid input: " + e.getMessage());  
	}
}
```
<br/>

Но это же неудобно! 

Собственно говоря, это идиоматический пример, когда имееет смысл пробросить исключение. 

```java
private static Scanner scanFile(String filename) 
		throws FileNotFoundException {  
	return new Scanner(new File(filename));  
}

public static void main(String[] args) {  
	try {  
		Scanner sc = scanFile("input.txt");  
		while (sc.hasNextInt()) {  
			System.out.print(sc.nextInt() + " ");  
		}  
	} catch (InputMismatchException e) {  
		System.out.println("invalid input: " + e.getMessage());  
	} catch (FileNotFoundException e) {  
		System.out.println("file not found: " + e.getMessage());  
	}
```

Не надо его пытаться здесь обрабатывать, мы *не знаем*, что с ним делать. 

Ну вот нам не удалось открыть файл на чтение. С точки зрения внешней программы может значить, что нужно сообщить пользователю, что файл должен быть. 

Вариант номер два, вполне нормально, что это какой то необязательный файл, тогда если нам не удалось его открыть для чтения, что это значит с точки зрения программы? Ничего, мы его просто проигнорировали. 

В любом случае, в методе ``scanFile`` недостаточно информации для обработки этого исключения, поэтому честно напишем, что метод пробрасывает исключение.

```java
private static Scanner scanFile(String filename)
		throws FileNotFoundException {  
	return new Scanner(new File(filename)); 
}  
```

<br/>

Тогда, разумеется, Java будет знать, что ``scanFile`` бросает исключение, тогда она заставит нас вернуть ``try-catch`` блок. Тут **важно**, что мы его будем обрабатывать ровно в том месте, когда мы знаем, что конкретно значит это исключение. У нас будут места, где неважно, они просто пробрасывают, однако мы найдем то место, где понятно, что с ним делать.

Итого --- неверно утверждение, что нужно всегда обрабатывать исключение в том же методе, где оно образовалось. Нет, есть куча методов, где более-чем логично пробрасывать исключение выше.

<br/>

## Файл мы открыли, а что дальше?

> Хорошо, теперь давайте представим, что мы хотим записать что-то в ``input.txt``. Сможем ли мы это сделать? 

На самом деле, это зависит много от чего. В чем проблема? 

У нас есть ``Scanner``, который читает файл ``input.txt``. Вопрос, можно ли записать в файл, открытый на чтение, зависит много от чего, и чаще всего ответ --- нет, хотя на некоторых OS ответ --- да.

<br/>

> Тогда вопрос --- когда ``Scanner`` отпустит файл? 

Для этого у ``Scanner`` есть метод ``close()``, позволяющий нам явно отпустить файл. 

```java
private static Scanner scanFile(String filename) 
		throws FileNotFoundException {  
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
		System.out.println("invalid input: " + e.getMessage());  
	} catch (FileNotFoundException e) {  
		System.out.println("file not found: " + e.getMessage());  
	}
```

Отлично, компилируется, метод ``close()`` не бросает исключения и освобождает ресурсы ``input.txt``. 

### Кто такой ваш этот ``finally``

> Правда ли, что мы точно теперь всегда сможем в ``input.txt`` записать? 

На самом деле нет. Если мы словим **FileNotFoundException**, то всё хорошо, так как сканнер не существовал и в природе. А вот если случился **InputMismatchException**, то возникают проблемы, потому что нужно не забыть закрыть сканнер! 
```java
try {  
	Scanner sc = scanFile("input.txt");  
	while (sc.hasNextInt()) {  
		System.out.print(sc.nextInt() + " ");  
	}  
	sc.close();  
} catch (InputMismatchException e) {  
	System.out.println("invalid input: " + e.getMessage());    
	sc.close();  
} catch (FileNotFoundException e) {  
	System.out.println("file not found: " + e.getMessage()); 
}
```

<br/>

Теперь всё хорошо?

Нет. У нас нет ``sc``, так как он определен в блоке ``try``, а переменные из разных блоков не видят друг друга! 

Хорошо, а вот так?
```java
Scanner sc;  
try {  
	sc = scanFile("input.txt"); // <-- мисматч может тут возникнуть
	while (sc.hasNextInt()) {  
		System.out.print(sc.nextInt() + " ");  
	}  
	sc.close();  
} catch (InputMismatchException e) {  
	System.out.println("invalid input: " + e.getMessage());   
	sc.close();  // <-- вот тут ошибка
} catch (FileNotFoundException e) {  
	System.out.println("file not found: " + e.getMessage()); 
}
```

<br/>

Опять нет. 

Компилятор говорит, что ``sc``  может быть даже не проинициализирован! С нашей точки зрения понятно, что **InputMismatchException** не может произойти до того как мы открыли сканнер, но с точки зрения Java --- это непроверяемое исключение, и оно может возникнуть где угодно. 

Давайте еще раз попытаемся исправить:

```java
Scanner sc = null;  
try {  
	sc = scanFile("input.txt");  
	while (sc.hasNextInt()) {  
		System.out.print(sc.nextInt() + " ");  
	}  
	sc.close();  
} catch (InputMismatchException e) {  
	System.out.println("invalid input: " + e.getMessage());  
	if (sc != null) sc.close(); 
} catch (FileNotFoundException e) {  
	System.out.println("file not found: " + e.getMessage()); 
}
```

<br/>

Ура, оно скомпилировалось! 

Значит ли это, что мы смогли защитить себя со всех сторон? Спойлер, нет. 

Если произошел **FileNotFoundException**, то закрывать нечего. Замечательно. 

Если произошел **InputMismatchException**, то мы проверили и закрыли, если надо. 

Но мало ли тут еще исключений может выскочить! А что если где-то в ``while`` выскочит еще одно непроверяемое исключение? Тогда мы не закроем наш сканнер. 

И что же делать? 

Нам нужно сделать какое-то действие вне зависимости от того произошло какое-то исключение или нет. Это совершенно типичная ситуация, для решения которой есть ``finally`` блок:

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
	System.out.println("invalid input: " + e.getMessage());
} catch (FileNotFoundException e) {  
	System.out.println("file not found: " + e.getMessage()); 
}
```
<br/>

Какова логика работы ``finally`` блока? 

Вы пошли в ``try`` блок, и вне зависимости от того, как закончился ``try`` блок, соответствующий ``finally`` блок будет выполнен. 

В целом это стандартная идиома --- взять ресурс, открыть его, поработать с ним, и не забыть в ``finally`` блоке его закрыть. Если это не сделать, то это приводит к, так называемым, утечкам ресурсов.

<br/>

> Гарантирует ли нам Java, что если не вызвать ``.close()``, будет ли файл открыт на чтение? 

Нет, не гарантирует, так как мы потеряли ссылку на ``Scanner``, и в любой момент может придти сборщик мусора и собрать ее, и это автоматически закроет вашу память. 

Проблема в том, что мы не можем предсказать когда это произойдет. То есть ресурсы утекли, через некоторое время они могут освободиться, а если у вас много памяти, и вы её всю не используете, то может никогда не освободятся.

Очень плохая история. Поэтому если вы в явной форме берете какие-то ресурсы, к примеру открываете файл на чтение или запись, пишите соовтетсвующий ``finally``-блок чтобы его закрыть.

<br/>

Теперь дальше. В целом в нашу конструкцию ``try-finally`` можно вписать произвольное количество блоков ``catch``. 

Если код внутри ``try`` не бросил исключение, то все ``catch`` блоки игнорируются, и выполняется ``finally`` блок. 

Если код бросил исключение, и оно поймано одним из ``catch`` блоков, то после его обработки выполнится ``finally`` блок. 

Если ни один из ``catch`` блоков не поймал исключение, то его пробросят дальше, однако ``finally`` блок всё равно будет исполнен.

```java
try {  
	Scanner sc = scanFile("input.txt");  
	try {  
		while (sc.hasNextInt()) {  
			System.out.print(sc.nextInt() + " ");  
		}  
	} catch (InputMismatchException e) {  
		System.out.println("invalid input: " + e.getMessage());
	} finally {  
		sc.close();  
	}  
} catch (FileNotFoundException e) {  
	System.out.println("file not found: " + e.getMessage()); 
}
``` 

<br/>

> Теперь вопрос на понимание --- можно ли ``catch`` блок с **FileNotFoundException** перенести вверх рядом с **InputMismatchException**? 

Нет, так **InputMismatchException** умеет вылетать только из внутреннего блока, а **FileNotFoundException** вылетает только из внешнего блока.

Еще раз повторю, это --- стандартная идиома для работы с ресурсами.

## Быстрый ввод и вывод, и кодировки

### Знакомство с ``Reader``'ом

Теперь вопрос про людей, пробовавших считать с помощью ``Scanner`` миллион чисел. Работает медленно, правда? 

Дело в том, что сам ``Scanner`` реализован на регулярных выражениях, и он ими постоянно пытается понять -- число, или не число.  Понятно, что в лабах и реальной жизни нам придётся считывать много чисел, поэтому мы научимся, как это делать быстро!

Для этого нам понадобятся классы ``Reader`` и ``Writer``.

Ну чтож, знакомьтесь с ``FileReader``. Как следует из его названия, он читает из файла. Тут же его закроем, чтобы не забыть позднее. 

```java
public static void main(String[] args) {  
	FileReader reader = new FileReader("java-test/input.txt");  
	try {  
		System.out.println(reader.read());  
	} finally {  
		reader.close();  
	}
}
```

Данный код не скомпилируется, и вылетит с ошибкой. Даже не одной, а тремя! Во первых **FileNotFoundException** при открытии, и бывает **IOException** при закрытии и попытке чтения. 

Давайте попытаемся их обработать, однако нужно быть внимательными, так как **FileNotFoundException** является **IOException**, и мы можем прострелить себе ногу, если будем ловить их не в том порядке. Но в нашем случае, это работает нам на руку.

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
	System.out.println("Input read error: " + e.getMessage());  
}
```
```java
104
```

<br/>

Должно вызвать недоумение. 

Программа сработала корректно, однако вместо ``hello`` мы получили 104. На самом деле всё хорошо, просто ``reader.read()`` читает один символ, и возвращает ``int``. 

```java
try {  
	FileReader reader = new FileReader("java-test/input.txt");  
	try {  
		System.out.println((char) reader.read());  
	} finally {  
		reader.close();  
	}  
} catch (IOException e) {  
	System.out.println("Input read error: " + e.getMessage());  
}
```
```java
h
```

<br/>

Давайте попытаемся прочитать весь ввод. 

Однако мы упремся в стандартную проблему --- как понять что мы прочитали весь файл? 

Когда ``.read()`` достиг конца, он возвращает -1. Именно поэтому, он возвращает ``int``, а не ``char``. Логика такая --- ``read()`` читает совершенно любой символ, поэтому нам нужно вернуть значение, которое совершенно точно не символ.

 Вот так прочитать весь ввод:
```java
try {  
	FileReader reader = new FileReader("java-test/input.txt");  
	try {  
		int input = reader.read();  
		if (input == -1) break;  
		System.out.println((char) input); 
	} finally {  
		reader.close();  
	}  
} catch (IOException e) {  
	System.out.println("Input read error: " + e.getMessage());  
}
```

<br/>

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

<br/>

Однако это имеет свою проблему. 

Давайте вспомним, что строчки в Java не изменяются, поэтому это работает за квадрат. Фактически мы копируем всю предыдущую часть строки и только потом добавлять. 

Но как тогда получить строчку? 

На помощь нам приходит замечательный класс ``StringBuilder``, у которого есть метод ``.append(char)``. Это гарантированно работает за линейное время, в отличии от складывания строк в цикле:

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

<br/>

Итого, мы производим чтение посимвольно, но для каждого символы мы обращаемся к операционной системе, и просим этот символ. К сожалению производительность этого кода ещё хуже чем у сканера. Есть два варианта решения проблемы.

Первый вариант --- можно считать за раз множество символов:

```java
try {  
	Reader reader = new FileReader("java-test/input.txt");
	try {
		char[] buffer = new char[5]; 
		while (true) {  
			int read = reader.read(buffer);  
			if (read == -1) break;
			for (int i = 0; i < read; i++) {
				System.out.print(buffer[i]);
			}
			System.out.println();  
		}
	} finally {  
		reader.close();  
	}  
} catch (IOException e) {  
	System.out.println("Input read error: " + e.getMessage());  
}
```

В этом случае ``read`` --- это количество символов, которые были прочитаны в ``buffer``, либо -1, если данные закончились. При этом в самом ``buffer`` гарантируется, что только первые ``read`` символов имеют смысл, в других может лежать просто какая-то рандомная информация.

Заметьте, что окончание файла это совершенно штатная ситуация, и бросать исключения по этому поводу не имеет смысла. Исключения только для нештатных ситуаций.

<br/>
<br/>

Второй вариант --- обернуть наш ``FileReader`` в ``BufferedReader``. Он, как следует из названия, буфферизованный и у него внутри есть тот самый буффер с которым он ходит в OS и просит отдельный символ. Теперь у нас нак каждый отдельный символ syscall не происходит. Ура, мы сэкономили!

Кроме того, у него есть полезный метод ``readLine``. Метод возвращает, очевидно, ``String``, а если все закончилось, то вернет то значение, которое не могло быть прочитано из файла --- к примеру ``null``.

```java
try {  
	Reader reader = new BufferedReader(
		new FileReader("java-test/input.txt")
	); 
	try {
		while (true) {  
			String line = reader.readLine();
			if (line == null) break;
			System.out.println(line);  
		}
	} finally {  
		reader.close();  
	}  
} catch (IOException e) {  
	System.out.println("Input read error: " + e.getMessage());  
}
```

*Примечание номер один*: что вообще такое строчка это нетривиальная вещь, и зависит от OS компьютера. Например в Windows окончание строки стандартное это CR и LF, в Linux или Unix это отдельный LF, в MacOS это отдельный \r. В целом в юникоде переводов строк много. Поэтому либо узнаете перевод строки в вашей OS, либо пользуетесь стандартным методом.

*Примечание номер два*: а что если там строчечка на несколько гигабайт. Очень грустно.

Поэтому не очень хорошо пользоваться именно ``readLine``  непосредственно. 

### Кодировки

Давайте проверим, можно ли напрямую сказать про кодировку.

```java
try {  
	Reader reader = new BufferedReader(
		new FileReader("java-test/input.txt", "utf8")
	); 
	try {
		while (true) {  
			String line = reader.readLine();
			if (line == null) break;
			System.out.println(line);  
		}
	} finally {  
		reader.close();  
	}  
} catch (IOException e) {  
	System.out.println("Input read error: " + e.getMessage());  
}
```
```
[input.txt] UTF-8
Привет
```
```
[System.out] UTF-8
Привет
```

Работает. Круто, но есть проблема.

Вариант номер два это у вас не слишком свежая Java, и это не будет поддерживаться, тогда конструкция выглядит следующим забавным образом:

```java
try {  
	Reader reader = new BufferedReader(
		new InputStreamReader(
			new FileInputStream("java-test/input.txt"),
			"utf8"
		)
	); 
	try {
		while (true) {  
			String line = reader.readLine();
			if (line == null) break;
			System.out.println(line);  
		}
	} finally {  
		reader.close();  
	}  
} catch (IOException e) {  
	System.out.println("Input read error: " + e.getMessage());  
}
```

Внутри у нас будет ``InputStreamReader`` --- это такой же ``Reader``, просто он читает байтики, а не символы. Ему нужно передать откуда читаем байтики, это мы делаем из файла, поэтому там ``FileInputStream``. Дальше кодировка.

То есть мы открыли файл для ввода байт, проинтерпретировали его с использованием такой-то кодировки, и после чего этот ввод ещё и буфферизировали. И тогда всё также будет работать.

### Привет, ``Writer``

Как можно было догадаться, что раз есть ``Reader``, то есть и ``Writer``.

```java
try {  
	Reader in = new BufferedReader(
		new InputStreamReader(
			new FileInputStream("java-test/input.txt"),
			"utf8"
		)
	); 
	StringBuilder sb = new StringBuilder();
	try {
		while (true) {  
			String line = in.readLine();
			if (line == null) break;
			sb.append(line);
		}
	} finally {  
		in.close();  
	}
	
	Writer out = new FileWriter("java-test/output.txt");
	try {
		out.write(sb.toString());
	} finally {
		out.close();
	}
} catch (FileNotFoundException e) {  
	System.out.println("Cannot open file:" + e.getMessage());  
} catch (IOException e) {  
	System.out.println("Cannot read or write: " + e.getMessage());  
}
```

>Давайте ещё раз потренируем вашу интуицию. Всё ли хорошо с кодом?

Внезапно, код компилируется, и нет никаких не пойманных исключений. Что, правда ли, что код работает без исключений? 

Нет, он бросает проверяемое исключение. Но почему нам об этом Java не сказала?

Потому что мы их уже поймали во внешнем ``try``. Если у вас одинаковая обработка исключений, то не надо её дублировать.

> Сразу должен возникнуть вопрос --- а в какой кодировке он вывел текстовые данные? 

Он выведет в кодировке по умолчанию. У строчки нет кодировки, в которой она исходна ни в какой момент, нет, просто у виртуальной машины Java есть кодировка по умолчанию. Именно для этого, как и у ``Reader``'а нам нужно написать очень похожую конструкцию для ``Writer``'а:

```java
try {  
	Reader in = new BufferedReader(
		new InputStreamReader(
			new FileInputStream("java-test/input.txt"),
			"utf8"
		)
	); 
	StringBuilder sb = new StringBuilder();
	try {
		while (true) {  
			String line = in.readLine();
			if (line == null) break;
			sb.append(line);
		}
	} finally {  
		in.close();  
	}
	
	Writer out = new BufferedWriter(
		new OutputStreamReader(
			new FileOutputStream("java-test/output.txt"),
			"utf8"
		)
	); 
	try {
		out.write(sb.toString());
	} finally {
		out.close();
	}
} catch (FileNotFoundException e) {  
	System.out.println("Cannot open file:" + e.getMessage());  
} catch (IOException e) {  
	System.out.println("Cannot read or write: " + e.getMessage());  
}
```

(На [сайте курса](https://www.kgeorgiy.info/courses/prog-intro/index.html) есть более подробные примеры кода, если вы захотите посмотреть.)

<br/>

Давайте заметим, что если мы удалим один ``catch``, то код продолжит компилироваться:

```java
try {  
	Reader in = new BufferedReader(
		new InputStreamReader(
			new FileInputStream("java-test/input.txt"),
			"utf8"
		)
	); 
	StringBuilder sb = new StringBuilder();
	try {
		while (true) {  
			String line = in.readLine();
			if (line == null) break;
			sb.append(line);
		}
	} finally {  
		in.close();  
	}
	
	Writer out = new BufferedWriter(
		new OutputStreamReader(
			new FileOutputStream("java-test/output.txt"),
			"utf8"
		)
	); 
	try {
		out.write(sb.toString());
	} finally {
		out.close();
	}
} catch (IOException e) {  
	System.out.println("Cannot read or write: " + e.getMessage());  
}
```

> Возникает вопрос, а почему?

Если почитать документацию, то можно понять, что **FileNotFoundException** является **IOException**, поэтому Java это устраивает.

Более того, если мы поменяем эти два ``catch``'а местами, то Java это перестанет устраивать и она начнет нам сообщать, что **FileNotFoundException** уже пойман, потому что он являлся **IOException** и здесь мы его уже обработали.

В этом случае второй ``catch`` никогда не будет выполнен, а как мы знаем Java любит предупреждать, если у нас есть код, который никогда не будет выполнен.

Формально у нас не множество ``catch``-блоков, а именно последовательность, и мы попадаем в первый ``catch``-блок, совпадающий по типу.

### ``PrintWriter`` и его брат ``PrintStream``

Существует класс ``PrintWriter``, и его аналог ``PrintStream``. 

Преимуществом этих классов является то, что у них есть методы ``print()`` и ``println()``, более того ``System.out`` это просто экземпляр ``PrintStream``.

Но тогда возникает вопрос, что происходит с ошибками. 

> Что вообще происходит, когда в ``System.out`` мы не можем ничего вывести?

Происходит буквально ничего. Ошибка будет проигнорирована. Соответственно, можно ли использовать ``PrintWriter`` и ``PrintStream`` для того, чтобы надежно писать в файлы? 

Нельзя. Получается, вы писали в файл, где-то в середине у вас кончилось место на диске, но об этом никто не узнал. Плохая идея.

В целом, у них есть замечательный метод ``cheackError()``, который позволяет узнать произошла ли какая-то ошибка. К сожалению вы не сможете узнать, что это была за ошибка, но можно хотя бы узнать, что то вообще сломалось.

В целом использовать для сколько нибудь надежного кода ``PrintWriter`` и ``PrintStream`` не рекомендуется.


