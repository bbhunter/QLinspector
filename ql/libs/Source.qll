import java
import semmle.code.java.Maps

class InvocationHandler extends Interface {
  InvocationHandler() { this.hasQualifiedName("java.lang.reflect", "InvocationHandler") }
}

class Comparator extends Interface {
  Comparator() { 
      this.hasQualifiedName("java.util", "Comparator<>") or 
      this.hasQualifiedName("java.util", "Comparator") 
    }
}

class MapClass extends RefType{
    MapClass() {
        getASupertype+() instanceof MapType
    }
}

class ExternalizableType extends RefType {
  ExternalizableType() { hasName("java.io.Externalizable") }
}

class ObjectInputValidationType extends RefType {
  ObjectInputValidationType() { hasName("java.io.ObjectInputValidation") }
}

class MethodHandlerType extends RefType {
  MethodHandlerType() { 
      hasQualifiedName("javassist.util.proxy", "MethodHandler") or
      hasQualifiedName("org.jboss.weld.bean.proxy", "MethodHandler")
    }
}

// from gadget inspector (not tested)
class GroovyType extends RefType {
    GroovyType(){
        hasQualifiedName("org.codehaus.groovy.runtime", "InvokerHelper") or
        hasQualifiedName("groovy.lang", "MetaClass")
    }
}

class ObjectType extends RefType {
  ObjectType() { hasName("java.lang.Object") }
}


class ObjectFactoryType extends RefType {
    ObjectFactoryType() { 
        getASupertype*().hasQualifiedName("javax.naming.spi", "ObjectFactory")
     }
}

class MapSource extends Method {
    MapSource() {
      getDeclaringType().getASupertype*() instanceof MapClass and
      (
        hasName("get") or
        hasName("put")
      )
      
    }
}

class HashCode extends Method {
  HashCode(){
    hasName("hashCode")
  }
}

class Equals extends Method {
  Equals(){
    hasName("equals")
  }
}

class Compare extends Method {
    Compare() {
        getDeclaringType().getASupertype*() instanceof Comparator and
        hasName(["compare", "compareTo"])
    }
}

class SerializableMethods extends Method {
    SerializableMethods() {
        this.getDeclaringType().getASupertype*() instanceof TypeSerializable and (
            hasName("readObject") or
            hasName("readObjectNoData") or
            hasName("readResolve") 
        )
    }
}

class ExternalizableMethod extends Callable {
    ExternalizableMethod(){
        this.getDeclaringType().getASupertype*() instanceof ExternalizableType and
        hasName("readExternal")
    }
}

class ObjectInputValidationMethod extends Callable {
    ObjectInputValidationMethod(){
        this.getDeclaringType().getASupertype*() instanceof ObjectInputValidationType and
        hasName("validateObject")
    }
}

class ObjectMethod extends Callable {
    ObjectMethod(){
        hasName("finalize") and
        getNumberOfParameters() = 0 and
        getAThrownExceptionType().hasQualifiedName("java.lang", "Throwable")
    }
}

// Cf CommonsCollections1
class InvocationHandlerMethod extends Callable {
    InvocationHandlerMethod(){
        this.getDeclaringType().getASupertype*() instanceof InvocationHandler and
        hasName("invoke")
    }
}

class MethodHandlerMethod extends Callable {
    MethodHandlerMethod(){
        this.getDeclaringType().getASupertype*() instanceof MethodHandlerType and
        hasName("invoke")
    }
}

// from gadget inspector (not tested)
class GroovyMethod extends Callable {
    GroovyMethod(){
        this.getDeclaringType().getASupertype*() instanceof GroovyType and (
            hasName("invokeMethod") or
            hasName("invokeConstructor") or 
            hasName("invokeStaticMethod")
        )
    }
}

// we can call a getter thanks to CommonBeanUtils1
// https://mogwailabs.de/en/blog/2023/04/look-mama-no-templatesimpl/
class CustomGetterMethod extends Callable { 
    CustomGetterMethod(){
        this.hasNoParameters() and
        this.getName().matches("get%")
    }
}

// Search for new ObjectFactories to replace BeanFactory
class ObjectFactoryMethod extends Callable {
    ObjectFactoryMethod(){
        this.getDeclaringType() instanceof ObjectFactoryType and
        this.hasName("getObjectInstance")
    }
}

class Source extends Callable {
    Source(){
        getDeclaringType().getASupertype*() instanceof TypeSerializable
    }
}

class GadgetSource extends Source {
    GadgetSource(){
        this instanceof MapSource or 
        this instanceof SerializableMethods or
        this instanceof Equals or
        this instanceof HashCode or
        this instanceof Compare or
        this instanceof ExternalizableMethod or 
        this instanceof ObjectInputValidationMethod or
        this instanceof InvocationHandlerMethod or
        this instanceof MethodHandlerMethod or
        this instanceof GroovyMethod or 
        this instanceof ToStringMethod
    }
}

// https://www.veracode.com/blog/research/exploiting-jndi-injections-java
class BeanFactorySource extends Callable {
    BeanFactorySource(){
        this.getNumberOfParameters() = 1 and
        this.getParameterType(0) instanceof TypeString and
        not this.isStatic()
    }
}

class CommonsBeanutilsSource extends Source {
    CommonsBeanutilsSource(){
        this instanceof CustomGetterMethod
    }
}