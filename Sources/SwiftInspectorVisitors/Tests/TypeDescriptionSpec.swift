// Created by Dan Federman on 2/2/21.
//
// Copyright © 2021 Dan Federman
//
// Distributed under the MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Nimble
import Quick
import SwiftInspectorTestHelpers
import SwiftSyntax

@testable import SwiftInspectorVisitors

final class TypeDescriptionSpec: QuickSpec {

  let simpleTestCase = TypeDescription.simple(
    name: "Foo",
    generics: [
      .simple(name: "Bar")
    ])
  let simpleTestCaseData = """
    {
      "caseDescription": "simple",
      "text": "Foo",
      "typeDescriptions": [{
        "caseDescription": "simple",
        "text": "Bar",
        "typeDescriptions": []
      }]
    }
    """.data(using: .utf8)!

  let nestedTestCase = TypeDescription.nested(
    name: "Bar",
    parentType: .simple(
      name: "Foo",
      generics: [.simple(name: "Int")]),
    generics: [.simple(name: "String")])
  let nestedTestCaseData = """
    {
      "typeDescriptions": [{
        "caseDescription": "simple",
        "text": "String",
        "typeDescriptions": []
      }],
      "caseDescription": "nested",
      "typeDescription": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": [{
          "caseDescription": "simple",
          "text": "Int",
          "typeDescriptions": []
      }]
      },
      "text": "Bar"
    }
    """.data(using: .utf8)!

  let optionalTestCase = TypeDescription.optional(.simple(name: "Foo"))
  let optionalTestCaseData = """
    {
      "caseDescription": "optional",
      "typeDescription": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": []
      }
    }
    """.data(using: .utf8)!

  let implicitlyUnwrappedOptionalTestCase = TypeDescription.implicitlyUnwrappedOptional(.simple(name: "Foo"))
  let implicitlyUnwrappedOptionalTestCaseData = """
    {
      "caseDescription": "implicitlyUnwrappedOptional",
      "typeDescription": {
        "caseDescription":"simple",
        "text":"Foo",
        "typeDescriptions":[]
      }
    }
    """.data(using: .utf8)!

  let compositionTestCase = TypeDescription.composition(
    [
      .simple(name: "Foo"),
      .optional(.simple(name: "Bar")),
    ])
  let compositionTestCaseData = """
    {
      "caseDescription": "composition",
      "typeDescriptions": [
        {
          "caseDescription": "simple",
          "text": "Foo",
          "typeDescriptions": []
        },
        {
          "caseDescription": "optional",
          "typeDescription": {
            "caseDescription": "simple",
            "text": "Bar",
            "typeDescriptions": []
          }
        }
      ]
    }
    """.data(using: .utf8)!

  let metatypeTestCase = TypeDescription.metatype(
    .simple(name: "Foo"),
    isType: false)
  let metatypeTestCaseData = """
    {
      "caseDescription": "metatype",
      "typeDescription": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": []
      },
      "isType": false
    }
    """.data(using: .utf8)!

  let someTestCase = TypeDescription.some(
    .simple(name: "Foo"))
  let someTestCaseData = """
    {
      "caseDescription": "some",
      "typeDescription": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": []
      },
    }
    """.data(using: .utf8)!

  let attributedTestCase = TypeDescription.attributed(
    .simple(name: "Foo"),
    specifier: "inout",
    attributes: ["autoclosure"])
  let attributedTestCaseData = """
    {
      "caseDescription": "attributed",
      "typeDescription": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": []
      },
      "specifier": "inout",
      "attributes": ["autoclosure"],
    }
    """.data(using: .utf8)!

  let arrayTestCase = TypeDescription.array(element: .simple(name: "Foo"))
  let arrayTestCaseData = """
    {
      "caseDescription": "array",
      "typeDescription": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": []
      }
    }
    """.data(using: .utf8)!

  let dictionaryTestCase = TypeDescription.dictionary(
    key: .simple(name: "Foo"),
    value: .simple(name: "Bar"))
  let dictionaryTestCaseData = """
    {
      "caseDescription": "dictionary",
      "dictionaryKey": {
        "caseDescription": "simple",
        "text": "Foo",
        "typeDescriptions": []
      },
      "dictionaryValue": {
        "caseDescription": "simple",
        "text": "Bar",
        "typeDescriptions": []
      }
    }
    """.data(using: .utf8)!

  let tupleTestCase = TypeDescription.tuple(
    [
      .simple(name: "Foo"),
      .optional(.simple(name: "Bar"))
    ])
  let tupleTestCaseData = """
    {
      "caseDescription": "tuple",
      "typeDescriptions": [
        {
          "caseDescription": "simple",
          "text": "Foo",
          "typeDescriptions": []
        },
        {
          "caseDescription": "optional",
          "typeDescription":
          {
            "caseDescription": "simple",
            "text": "Bar",
            "typeDescriptions": []
          }
        }
      ]
    }
    """.data(using: .utf8)!

  let closureTestCase = TypeDescription.closure(
    arguments: [
      .simple(name: "Foo"),
      .optional(.simple(name: "Bar"))
    ],
    doesThrow: true,
    returnType: .simple(name: "FooBar"))
  let closureTestCaseData = """
    {
      "caseDescription": "closure",
      "closureArguments": [
        {
          "caseDescription": "simple",
          "text": "Foo",
          "typeDescriptions": []
        },
        {
          "caseDescription": "optional",
          "typeDescription":
          {
            "caseDescription": "simple",
            "text": "Bar",
            "typeDescriptions": []
          }
        }
      ],
      "closureThrows": true,
      "closureReturn": {
        "caseDescription": "simple",
        "text": "FooBar",
        "typeDescriptions": []
      }
    }
    """.data(using: .utf8)!

  let unknownTestCase = TypeDescription.unknown(text: "Foo")
  let unknownTestCaseData = """
    {
      "caseDescription": "unknown",
      "text": "Foo"
    }
    """.data(using: .utf8)!


  override func spec() {
    describe("When decoding previously persisted TypeDescription data") {
      let decoder = JSONDecoder()
      var data: Data!

      context("that represents a simple type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.simpleTestCaseData)) == self.simpleTestCase
        }
      }

      context("that represents a nested type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.nestedTestCaseData)) == self.nestedTestCase
        }
      }

      context("that represents an optional type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.optionalTestCaseData)) == self.optionalTestCase
        }
      }

      context("that represents an implicitlyUnwrappedOptional type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.implicitlyUnwrappedOptionalTestCaseData)) == self.implicitlyUnwrappedOptionalTestCase
        }
      }

      context("that represents a composition type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.compositionTestCaseData)) == self.compositionTestCase
        }
      }

      context("that represents a metatype") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.metatypeTestCaseData)) == self.metatypeTestCase
        }
      }

      context("that represents a some-restricted type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.someTestCaseData)) == self.someTestCase
        }
      }

      context("that represents an attributed type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.attributedTestCaseData)) == self.attributedTestCase
        }
      }

      context("that represents an array type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.arrayTestCaseData)) == self.arrayTestCase
        }
      }

      context("that represents a dictionary type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.dictionaryTestCaseData)) == self.dictionaryTestCase
        }
      }

      context("that represents a tuple type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.tupleTestCaseData)) == self.tupleTestCase
        }
      }

      context("that represents a closure type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.closureTestCaseData)) == self.closureTestCase
        }
      }

      context("that represents an unknown type") {
        it("decodes the encoded type description") {
          expect(try decoder.decode(TypeDescription.self, from: self.unknownTestCaseData)) == self.unknownTestCase
        }
      }

      context("that represents an unknown case") {
        beforeEach {
          data = """
            {
              "caseDescription": "garbage"
            }
            """.data(using: .utf8)!
        }

        it("throws") {
          expect(try decoder.decode(TypeDescription.self, from: data)).to(throwError(TypeDescription.CodingError.unknownCase))
        }
      }
    }

    describe("When decoding a TypeDescription data created with the current library version") {
      let decoder = JSONDecoder()
      let encoder = JSONEncoder()

      context("utilizing a simple type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.simpleTestCase))) == self.simpleTestCase
        }
      }

      context("utilizing a nested type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.nestedTestCase))) == self.nestedTestCase
        }
      }

      context("utilizing an optional type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.optionalTestCase))) == self.optionalTestCase
        }
      }

      context("utilizing an implicitlyUnwrappedOptional type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.implicitlyUnwrappedOptionalTestCase))) == self.implicitlyUnwrappedOptionalTestCase
        }
      }

      context("utilizing a composition type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.compositionTestCase))) == self.compositionTestCase
        }
      }

      context("utilizing a metatype") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.metatypeTestCase))) == self.metatypeTestCase
        }
      }

      context("utilizing a some-restricted type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.someTestCase))) == self.someTestCase
        }
      }

      context("utilizing an attributed type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.attributedTestCase))) == self.attributedTestCase
        }
      }

      context("utilizing an array type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.arrayTestCase))) == self.arrayTestCase
        }
      }

      context("utilizing a dictionary type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.dictionaryTestCase))) == self.dictionaryTestCase
        }
      }

      context("utilizing a tuple type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.tupleTestCase))) == self.tupleTestCase
        }
      }

      context("utilizing a closure type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.closureTestCase))) == self.closureTestCase
        }
      }

      context("utilizing an unknown type") {
        it("successfully decodes the data") {
          expect(try decoder.decode(TypeDescription.self, from: try encoder.encode(self.unknownTestCase))) == self.unknownTestCase
        }
      }
    }

    describe("typeDescription") {
      context("when called on a TypeSyntax node representing a SimpleTypeIdentifierSyntax") {
        final class SimpleTypeIdentifierSyntaxVisitor: SyntaxVisitor {
          var simpleTypeIdentifier: TypeDescription?
          override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
            simpleTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: SimpleTypeIdentifierSyntaxVisitor!
        beforeEach {
          let content = """
              var int: Int = 1
              """

          visitor = SimpleTypeIdentifierSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor?.simpleTypeIdentifier?.asSource) == "Int"
        }
      }

      context("when called on a TypeSyntax node representing a MemberTypeIdentifierSyntax") {
        final class MemberTypeIdentifierSyntaxVisitor: SyntaxVisitor {
          var nestedTypeIdentifier: TypeDescription?
          override func visit(_ node: MemberTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
            nestedTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: MemberTypeIdentifierSyntaxVisitor!
        context("without a generic argument") {
          beforeEach {
            let content = """
              var int: Swift.Int = 1
              """

            visitor = MemberTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor?.nestedTypeIdentifier?.asSource) == "Swift.Int"
          }
        }

        context("with a right-hand generic argument") {
          beforeEach {
            let content = """
              var intArray: Swift.Array<Int> = [1]
              """

            visitor = MemberTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor?.nestedTypeIdentifier?.asSource) == "Swift.Array<Int>"
          }
        }

        context("with a left-hand generic argument") {
          beforeEach {
            let content = """
              var genericType: OuterGenericType<Int>.InnerType
              """

            visitor = MemberTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor?.nestedTypeIdentifier?.asSource) == "OuterGenericType<Int>.InnerType"
          }
        }

        context("with a generic arguments on both sides") {
          beforeEach {
            let content = """
              var genericType: OuterGenericType<Int>.InnerGenericType<String>
              """

            visitor = MemberTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor?.nestedTypeIdentifier?.asSource) == "OuterGenericType<Int>.InnerGenericType<String>"
          }
        }
      }

      context("when called on a TypeSyntax node representing a CompositionTypeSyntax") {
        final class CompositionTypeSyntaxVisitor: SyntaxVisitor {
          var composedTypeIdentifier: TypeDescription?
          // Note: ideally we'd visit a node of type CompositionTypeElementListSyntax
          // but there's no easy way to get a TypeSyntax from an object of that type.
          override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
            composedTypeIdentifier = node.typeName.typeDescription
            return .skipChildren
          }
        }

        var visitor: CompositionTypeSyntaxVisitor!
        beforeEach {
          let content = """
            protocol FooBar: Foo & Bar
            """

          visitor = CompositionTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the types") {
          expect(visitor?.composedTypeIdentifier?.asSource) == "Foo & Bar"
        }
      }

      context("when called on a TypeSyntax node representing a OptionalTypeSyntax") {
        final class OptionalTypeSyntaxVisitor: SyntaxVisitor {
          var optionalTypeIdentifiers = [TypeDescription]()
          override func visit(_ node: SameTypeRequirementSyntax) -> SyntaxVisitorContinueKind {
            optionalTypeIdentifiers += [
              node.leftTypeIdentifier.typeDescription,
              node.rightTypeIdentifier.typeDescription
            ]
            return .skipChildren
          }
        }

        var visitor: OptionalTypeSyntaxVisitor!
        beforeEach {
          let content = """
            protocol FooBar: Foo where Something == AnyObject? {}
            """

          visitor = OptionalTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor?.optionalTypeIdentifiers
                  .map { $0.asSource }
                  .contains("AnyObject?"))
            .to(beTrue())
        }
      }

      context("when called on a TypeSyntax node representing a ImplicitlyUnwrappedOptionalTypeSyntax") {
        final class ImplicitlyUnwrappedOptionalTypeSyntaxVisitor: SyntaxVisitor {
          var implictlyUnwrappedOptionalTypeIdentifier: TypeDescription?
          override func visit(_ node: ImplicitlyUnwrappedOptionalTypeSyntax) -> SyntaxVisitorContinueKind {
            implictlyUnwrappedOptionalTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: ImplicitlyUnwrappedOptionalTypeSyntaxVisitor!
        beforeEach {
          let content = """
            var int: Int!
            """

          visitor = ImplicitlyUnwrappedOptionalTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor?.implictlyUnwrappedOptionalTypeIdentifier?.asSource) == "Int!"
        }
      }

      context("when called on a TypeSyntax node representing a MetatypeTypeSyntax") {
        final class MetatypeTypeSyntaxVisitor: SyntaxVisitor {
          var metatypeTypeIdentifier: TypeDescription?
          override func visit(_ node: MetatypeTypeSyntax) -> SyntaxVisitorContinueKind {
            metatypeTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: MetatypeTypeSyntaxVisitor!
        context("that represents a type") {
          beforeEach {
            let content = """
            let metatype: Int.Type
            """

            visitor = MetatypeTypeSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.metatypeTypeIdentifier?.asSource) == "Int.Type"
          }
        }

        context("that represents a protocol") {
          beforeEach {
            let content = """
            let metatype: Equatable.Protocol
            """

            visitor = MetatypeTypeSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.metatypeTypeIdentifier?.asSource) == "Equatable.Protocol"
          }
        }
      }

      context("when called on a TypeSyntax node representing a SomeTypeSyntax") {
        final class SomeTypeSyntaxVisitor: SyntaxVisitor {
          var someTypeIdentifier: TypeDescription?
          override func visit(_ node: ConstrainedSugarTypeSyntax) -> SyntaxVisitorContinueKind {
            someTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: SomeTypeSyntaxVisitor!
        beforeEach {
          let content = """
            func makeSomething() -> some Equatable { "" }
            """

          visitor = SomeTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor.someTypeIdentifier?.asSource) == "some Equatable"
        }
      }

      context("when called on a TypeSyntax node representing an AttributedTypeSyntax") {
        final class AttributedTypeSyntaxVisitor: SyntaxVisitor {
          var attributedTypeIdentifier: TypeDescription?
          override func visit(_ node: AttributedTypeSyntax) -> SyntaxVisitorContinueKind {
            attributedTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: AttributedTypeSyntaxVisitor!
        context("with a specifier") {
          beforeEach {
            let content = """
            inout Int
            """

            visitor = AttributedTypeSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.attributedTypeIdentifier?.asSource) == "inout Int"
          }
        }

        context("with attributes") {
          beforeEach {
            let content = """
            @autoclosure () -> Void
            """

            visitor = AttributedTypeSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.attributedTypeIdentifier?.asSource) == "@autoclosure () -> Void"
          }

          context("with a specifier and attributes") {
            beforeEach {
              let content = """
              // This code doesn't compile but it can be parsed.
              inout @autoclosure () -> Void
              """

              visitor = AttributedTypeSyntaxVisitor()
              try? visitor.walkContent(content)
            }

            it("Finds the type") {
              expect(visitor.attributedTypeIdentifier?.asSource) == "inout @autoclosure () -> Void"
            }
          }
        }
      }

      context("when called on a TypeSyntax node representing an ArrayTypeSyntax") {
        final class ArrayTypeSyntaxVisitor: SyntaxVisitor {
          var arrayTypeIdentifier: TypeDescription?
          override func visit(_ node: ArrayTypeSyntax) -> SyntaxVisitorContinueKind {
            arrayTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: ArrayTypeSyntaxVisitor!
        beforeEach {
          let content = """
            var intArray: [Int] = [Int]()
            """

          visitor = ArrayTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor.arrayTypeIdentifier?.asSource) == "Array<Int>"
        }
      }

      context("when called on a TypeSyntax node representing an array not of form ArrayTypeSyntax") {
        final class SimpleTypeIdentifierSyntaxVisitor: SyntaxVisitor {
          var typeIdentifier: TypeDescription?
          override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
            typeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: SimpleTypeIdentifierSyntaxVisitor!
        context("when the array is one-dimensional") {
          beforeEach {
            let content = """
            var intArray: Array<Int>
            """

            visitor = SimpleTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.typeIdentifier?.asSource) == "Array<Int>"
          }
        }

        context("when the array is two-dimensional") {
          beforeEach {
            let content = """
            var twoDimensionalIntArray: Array<Array<Int>>
            """

            visitor = SimpleTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.typeIdentifier?.asSource) == "Array<Array<Int>>"
          }
        }

      }

      context("when called on a TypeSyntax node representing a DictionaryTypeSyntax") {
        final class DictionaryTypeSyntaxVisitor: SyntaxVisitor {
          var dictionaryTypeIdentifier: TypeDescription?
          override func visit(_ node: DictionaryTypeSyntax) -> SyntaxVisitorContinueKind {
            dictionaryTypeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: DictionaryTypeSyntaxVisitor!
        beforeEach {
          let content = """
            var dictionary: [Int: String] = [Int: String]()
            """

          visitor = DictionaryTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor.dictionaryTypeIdentifier?.asSource) == "Dictionary<Int, String>"
        }
      }

      context("when called on a TypeSyntax node representing a dictionary not of form DictionaryTypeSyntax") {
        final class SimpleTypeIdentifierSyntaxVisitor: SyntaxVisitor {
          var typeIdentifier: TypeDescription?
          override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
            typeIdentifier = TypeSyntax(node).typeDescription
            return .skipChildren
          }
        }

        var visitor: SimpleTypeIdentifierSyntaxVisitor!
        context("when the dictionary is one-dimensional") {
          beforeEach {
            let content = """
            var dictionary: Dictionary<Int, String>
            """

            visitor = SimpleTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.typeIdentifier?.asSource) == "Dictionary<Int, String>"
          }
        }

        context("when the dictionary is two-dimensional") {
          beforeEach {
            let content = """
            var twoDimensionalDictionary: Dictionary<Int, Dictionary<Int, String>>
            """

            visitor = SimpleTypeIdentifierSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor.typeIdentifier?.asSource) == "Dictionary<Int, Dictionary<Int, String>>"
          }
        }
      }

      context("when called on a TypeSyntax node representing a TupleTypeSyntax") {
        final class TupleTypeSyntaxVisitor: SyntaxVisitor {
          var tupleTypeIdentifier: TypeDescription?
          // Note: ideally we'd visit a node of type TupleTypeElementListSyntax
          // but there's no easy way to get a TypeSyntax from an object of that type.
          override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
            tupleTypeIdentifier = node.type.typeDescription
            return .skipChildren
          }
        }

        var visitor: TupleTypeSyntaxVisitor!
        beforeEach {
          let content = """
              var tuple: (Int, String)
              """

          visitor = TupleTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds the type") {
          expect(visitor?.tupleTypeIdentifier?.asSource) == "(Int, String)"
        }
      }

      context("when called on a TypeSyntax node representing a ClassRestrictionTypeSyntax") {
        final class ClassRestrictionTypeSyntaxVisitor: SyntaxVisitor {
          var classRestrictionIdentifier: TypeDescription?
          // Note: ideally we'd visit a node of type ClassRestrictionTypeSyntax
          // but there's no way to get a TypeSyntax from an object of that type.
          override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
            classRestrictionIdentifier = node.typeName.typeDescription
            return .skipChildren
          }
        }

        var visitor: ClassRestrictionTypeSyntaxVisitor!
        beforeEach {
          let content = """
              protocol SomeObject: class {}
              """

          visitor = ClassRestrictionTypeSyntaxVisitor()
          try? visitor.walkContent(content)
        }

        it("Finds returns the type as AnyObject") {
          expect(visitor?.classRestrictionIdentifier?.asSource) == "AnyObject"
        }
      }

      context("when called on a TypeSyntax node representing a FunctionTypeSyntax") {
        final class FunctionTypeSyntaxVisitor: SyntaxVisitor {
          var functionIdentifier: TypeDescription?
          // Note: ideally we'd visit a node of type FunctionTypeSyntax
          // but there's no way to get a TypeSyntax from an object of that type.
          override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
            functionIdentifier = node.type.as(TypeSyntax.self)?.typeDescription
            return .skipChildren
          }
        }

        context("on a function that does not throw") {
          var visitor: FunctionTypeSyntaxVisitor!
          beforeEach {
            let content = """
                var test: (Int, Double) -> String
                """

            visitor = FunctionTypeSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds the type") {
            expect(visitor?.functionIdentifier?.asSource) == "(Int, Double) -> String"
          }
        }

        context("on a function that throws") {
          var visitor: FunctionTypeSyntaxVisitor!
          beforeEach {
            let content = """
                var test: (Int, Double) throws -> String
                """

            visitor = FunctionTypeSyntaxVisitor()
            try? visitor.walkContent(content)
          }

          it("Finds that the type throws") {
            expect(visitor?.functionIdentifier?.asSource) == "(Int, Double) throws -> String"
          }
        }
      }

    }

    describe("asSource") {
      context("when describing an unknown case") {
        let sut = TypeDescription.unknown(text: " SomeTypeThatIsFormattedOddly  ")

        it("returns the provided string with whitespace stripped") {
          expect(sut.asSource) == "SomeTypeThatIsFormattedOddly"
        }
      }
    }
  }
}
