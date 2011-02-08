
--import java.util.LinkedList;
--import java.util.Random;
--import javax.swing.*;

--[[
/*
 *	Engine to render stories using a BNF.
 *
 * 	TODO: Add check if current symbol char is already in use.
 * 	TODO: Add toString methods.
 */
public class NarrativeEngine {

	// Symbol: For terminating and non-terminating symbols in the lexikon.
	//		   Used for polymorphism when evaluating the string. Really needed??
	interface Symbol {
		String eval();
		Cluster _eval();	// fix 
	}

	LinkedList<Symbol> symbollist = new LinkedList<Symbol>();
	Random random 		= new Random();
	int		pos			= 0;	// position in the symbolstring

--]]

	symbollist = {}
	pos = 1				-- start on 1 in Lua

--[[

	NarrativeEngine() {
	}

    public static void main(String[] args) {
		NarrativeEngine ne = new NarrativeEngine();
		ne.run();
	}

	public int run() {

		/*
			Test grammar:
				A -> a | B
				B -> b | A | NIL
		*/

		// Init symbols
		Symbol a = new Term('a', "Norse expands");
		Symbol b = new Term('b', "Norse freezes");
		NonTerm A = new NonTerm('A');
		NonTerm B = new NonTerm('B');
		Cluster cluster_a = new Cluster(0.5f, a);
		Cluster cluster_b = new Cluster(0.33f, b);
		Cluster cluster_A = new Cluster(0.33f, A);
		Cluster cluster_B = new Cluster(0.5f, B);

		// Insert clusters into the non-terminal symbols, creating rules
		A.addCluster(cluster_a);
		A.addCluster(cluster_B);
		B.addCluster(cluster_b);
		B.addCluster(cluster_A);
		B.addCluster(null);

		LinkedList<Symbol> l = new LinkedList<Symbol>();
		l.add(A);
		l.add(a);
		l.add(a);
		l.add(B);


		// link clusters
		//LinkedList<Cluster> clusterlist = new LinkedList<Cluster>();
		//clusterlist.add(cluster);

		// non-terminating symbol as productive rule/left-hand side
		//NonTerm W = new NonTerm(('W'), clusterlist);

		// link non-terminals
		//LinkedList<NonTerm> m = new LinkedList<NonTerm>();
		//m.add(W);

		// create ruleset as a list of non-terminals
		//RuleSet ruleset = new RuleSet(m, "Norse test");

		parseNontermsInSymlist(l);

		return 0;
	}
--]]

--[[
	/*
		Consumes the input string.
		The input string is any combination of terminal and non-terminal symbols, e.g. aabBbBBAb.
		First all non-terminal symbols are consumed in a bubble-sort fashion, always starting from position 0. This produces terminal symbols. Then all terminal symbols are parsed to their corresponding description, which is the actual "story".
	*/
	LinkedList<Symbol> parseNontermsInSymlist(LinkedList<Symbol> symlist) {

		int pos = 0;
		Symbol sym;
		int size = symlist.size();

		System.out.println(symlist.toString());

		// first iteration, consume all non-terminal symbols
		while (pos < size) {
			sym = symlist.get(pos);	// get current symbol
			if (sym instanceof NonTerm) {
				symlist.set(pos, sym._eval().getSymbols());
				System.out.println(symlist.toString());
				size = symlist.size();
				pos = -1; 		// start from beginning
			}
			pos++;
		}

		return symlist;
	}

	// ?
	class narrativeString {
		
	}

--]]

--[[
	/*
		The left-hand side of the grammar, a list of non-terminal symbols.
		E.g:
			A -> a | B
			B -> b | A | NIL

			Here the RuleSet would be [A,B], where A and B are NonTerm objects containg the production rules a | B and b | A | NIL. Symbols that are terminal corresponds to a string/describtion.
	*/
	class RuleSet {
		LinkedList<NonTerm> rules = new LinkedList<NonTerm>();
		String descr;

		RuleSet(LinkedList<NonTerm> r, String d) {
			rules = r;
			descr = d;
		}

		RuleSet() { }

		boolean addRule() { return false; }

		String eval() {
			Symbol s = symbollist.get(pos);		// simply start from the first symbol in list (because pos should here be 0)
			System.out.println("eval symbol " + s);
			return s.eval();
		}
	}
--]]


	-- Ruleset class --

	Ruleset = { rules = nil, desc = nil}
	
	function Ruleset:new(o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end

	-- This function parses the next non-terminal symbol in the narrative string.
	function Ruleset:parseNextNonTerm() 
		local sym = symbollist[pos]
		print()
		return sym.eval()
	end

--[[
	/*
		Right hand-side element of the grammar. Each clutser is a collection of symbols, representing an alternative, eg. A -> hmA | hm | AA | NIL 
		Each cluster has a probability of being chosen (can change over time).
	*/
	class Cluster {

		LinkedList<Symbol> 	symbolList = new LinkedList<Symbol>();
		float				prob;	// Probability of being selected. Dynamic. Relative (weight), depends on other weights in the cluster.
					    			// Ideally, all probs in a cluster adds up to 1.

		Cluster(LinkedList<Symbol> l, float p) {
			symbolList 	= l;
			prob 		= p;
		}

		Cluster(float p, Symbol sym) {
			prob = p;
			symbolList.add(sym);
		}

		Cluster(float p) { prob = p; }

		Cluster() {}

		void addSymbol(Symbol sym) { symbolList.add(sym); }

		//LinkedList<Symbol> getSymbols() {
		Symbol getSymbols() {
			return symbolList.getFirst();
		}

		@Override
		public String toString() {
			String s = "";

			for (Symbol t : symbolList) {
				s += t.toString();	
			}
			return s;
		}
	}

--]]

	-- Cluster class

	Cluster = { }
	
	function Cluster:new(l)
		o = {}
		setmetatable(o, self)
		self.__index = self
		--self.s = arg
		self.l = l
		return o
	end

	-- Sets probability for this cluster
	function Cluster:setProb(p) self.p = p end

	-- Sets the symbol list which will replace the non-term being evaluated
	function Cluster:setList(l) self.l = l end

--[[


	/* 
		Non-terminating symbol, might work as theme, place or phase in the story. Both left and right hand-side.

	*/
	class NonTerm implements Symbol {

		LinkedList<Cluster> clusterList = new LinkedList<Cluster>();	// Each non-terminating symbol has a collection of clusters.
		char	sign;
		String	descr;	// Describtion.
		float	totalProb; // Sum of all clusters probability. Should be one.

		NonTerm(char s, LinkedList<Cluster> cl) {
			sign 		= s;
			clusterList = cl;

			// Calculate total probabilityp
			totalProb = 0;
			for (Cluster c : clusterList) {
				totalProb += c.prob;
			}
		}

		NonTerm(char c) {
			sign = c;
		}

		void addCluster(Cluster c) { clusterList.add(c); }

		void setClusters(LinkedList<Cluster> clusters) { clusterList = clusters; }

		public Cluster _eval() {

			// Choose cluster 
			double r = random.nextDouble();
			for (Cluster c : clusterList) {
				if (r <= c.prob/totalProb) {	// Math!
					// Choose this cluster
					return c;
				}
				else {
					r -= c.prob;
				}
			}

			// No cluster was chosen??
			return null;
		}
	
		public String eval() { return null; }

		public String toString() {
			return String.valueOf(sign);
		}
	}

	// Terminating symbol, in this case events or choises for the hero.
	class Term implements Symbol {

		char	sign;
		String	descr;

		Term(char c, String d) {
			sign 	= c;
			descr 	= d;
		}

		public String eval() {
			//textArea.append(descr);
			System.out.println("eval term, descr = " + descr);
			return null;
		}

		public Cluster _eval() { return null; }

		public String toString() {
			return String.valueOf(sign);
		}
	}
}
--]]


	--[[
		Symbol class, for both terminal and non-terminal symbols.
		
		Each terminal symbol has an associated description.

		Each non-terminal symbol has a list of clusters.
	--]]

	Symbol = {}
	
	function Symbol:newTerm(c)
		o = {}
		setmetatable(o, self)
		self.__index = self
		self.c = c
		return o
	end

	function Symbol:newNonTerm()
		o = {}
		setmetatable(o, self)
		self.__index = self
		return o
	end

	-- Sets the description for a terminal symbol
	function Symbol:setDesc(desc)
		self.desc = desc
	end
	
	-- Sets cluster for non-terminal symbols
	function Symbol:setCluster(cluster)
		self.cluster = cluster
	end


	-- Some tests

	function dump(var)
		for k, v in ipairs(var) do
			print(v)
		end
	end

	s1 = Symbol:newTerm('a')
	s2 = Symbol:newTerm('b')

	c1 = Cluster:new({s1, s2})
	print(dump(c1.l))

