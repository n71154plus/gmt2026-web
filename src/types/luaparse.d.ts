declare module 'luaparse' {
  export interface ASTNode {
    type: string;
    loc?: {
      start: { line: number; column: number };
      end: { line: number; column: number };
    };
    range?: [number, number];
    [key: string]: any;
  }

  export interface ParserOptions {
    lax?: boolean;
    scope?: boolean;
    locations?: boolean;
    ranges?: boolean;
    comments?: boolean;
    luaVersion?: '5.1' | '5.2' | '5.3' | 'jit';
    extendedIdentifiers?: boolean;
  }

  interface ParseFunction {
    (code: string, options?: ParserOptions): ASTNode;
  }

  const luaparse: {
    parse: ParseFunction;
  };

  export default luaparse;
}
