using System;
using System.Collections.Generic;

using CLIPSNET;
namespace Example
{
    class Program
    {
        static void Main(string[] args)
        {
            CLIPSNET.Environment clips = new CLIPSNET.Environment();
            clips.Build("(deftemplate person (slot name) (slot age))");
            clips.AssertString("(person (name \"Fred Jones\") (age 17))");
            clips.AssertString("(person (name \"Sally Smith\") (age 23))");
            clips.AssertString("(person (name \"Wally North\") (age 35))");
            clips.AssertString("(person (name \"Jenny Wallis\") (age 11))");
            Console.WriteLine("All people:");
            List<FactAddressValue> people = clips.FindAllFacts("person");
            foreach (FactAddressValue p in people)
            { Console.WriteLine(" " + p["name"]); }
            Console.WriteLine("All adults:");
            people = clips.FindAllFacts("?f", "person", "(>= ?f:age 18)");
            foreach (FactAddressValue p in people)
            { Console.WriteLine(" " + p["name"]); }
        }
    }
}