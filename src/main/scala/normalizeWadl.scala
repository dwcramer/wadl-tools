package com.rackspace.cloud.api.wadl

import java.io.File
import org.fud.optparse._

import scala.xml._

import javax.xml.validation._
import org.xml.sax.SAXException

import java.net.URL

import javax.xml.transform._
import javax.xml.transform.stream._
import java.io.ByteArrayInputStream

import java.io.StringReader
import javax.xml.transform.stream.StreamSource

import java.io.FileNotFoundException

import com.rackspace.cloud.api.wadl.WADLNormalizer
import com.rackspace.cloud.api.wadl.WADLFormat._
import com.rackspace.cloud.api.wadl.XSDVersion._
import com.rackspace.cloud.api.wadl.RType._
import com.rackspace.cloud.api.wadl.Converters._

object normalizeWadl {

  def main(args: Array[String]) {
    var options = Map[Symbol, Any]('format -> "", 
				   'flatten -> true, 
				   'version -> "1.0", 
				   'omitResourceTypes -> false)

    var libs = List[File]()

    val cli = 
  new OptionParser {

        banner = "normalizeWadl [options] wadl-file"
        separator("")
        separator("Options: ")

        reqd[String]("-v <version>", "--xsd-version <version>",List("1.0","1.1"), "XSD Version....")
        { v => options += 'version -> v }

        reqd[String]("-f <format>", "--format <path|tree|dont>", List("path","tree"), "Format for wadl...")
        { v => options += 'format -> v }

        flag("-x", "--flatten-xsds", "Flatten xsds")
        { () => options += 'flatten -> true }

        flag("-r", "--omit-resource_types", "Omit resource_types")
        { () => options += 'omitResourceTypes -> true }
      }

    val file_args = try{ 
      cli.parse(args)      
    }catch { case e: OptionParserException => println(e.getMessage); sys.exit(1) }

    // println("Options: " + options)
    // println("File Args: " + file_args)
    if(file_args.length != 1) println("""
				      No wadl specified! 				      

				      """ + cli.help)


   val format: com.rackspace.cloud.api.wadl.WADLFormat.Format = options('format) match {
     case "path" => PATH
     case "tree" => TREE
     case _ => DONT
   }

   val version: com.rackspace.cloud.api.wadl.XSDVersion.Version = options('version) match {
     case "1.1" => XSD11
     case _ => XSD10
   }

   val rtypes: com.rackspace.cloud.api.wadl.RType.ResourceType = options('omitResourceTypes) match {
     case true => OMIT
     case _ => KEEP
   }					      


   val wadl = new WADLNormalizer()

   val result = new StreamResult(new File("foo.wadl"));

   val normWadl = wadl.normalize("file://" + file_args.head,
				 result,
   				 format, 
   				 version, 
   				 options('flatten).asInstanceOf[Boolean], 
   				 rtypes)
					      
   // TODO: 
   //  * Validate the generated wadl and xsds
   //  * Control where output lands (same as current script? Add flexiblity?

      // FIXME: Validate the result of the normalize rather than files on the file system?
      // TODO: Find all the xsds that match the naming pattern?
      val wadlFile = scala.xml.XML.loadFile("foo.wadl")
      val factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema")
      // FIXME: 
      // 1) Fix hardcoded absolute path to wadl.xsd
      // 2) Use new version of Xerces for xsd 1.1
      val wadlSchema = factory.newSchema(new URL("file:///home/dcramer/rax/wadl-tools/xsd/wadl.xsd"))
      val validator = wadlSchema.newValidator()    
      implicit def toStreamSource(x:Elem) = new StreamSource(new StringReader(x.toString))
      try{
	validator.validate(wadlFile)
      }catch {
	case se : SAXParseException => println("""
=============================
The source wadl is not valid:
""" + se + """
============================= 
"""); sys.exit(1) }


  }
}



