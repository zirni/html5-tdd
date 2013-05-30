# encoding: utf-8
require "rspec"
require "ostruct"
require "nokogiri"
require 'equalizer'
require "curb"

class Example1
INVALID_HTML = "<!DOCTYPE html>
<html lang='en'>
<head>
<title>title</title>
<meta charset='utf-8'>
<meta content='content' name='description'>
</head>
<body>
<img>
</body>
</html>".freeze

VALID_HTML = "<!DOCTYPE html>
<html lang='en'>
<head>
<title>title</title>
<meta charset='utf-8'>
<meta content='content' name='description'>
</head>
<body>
</body>
</html>".freeze
end

class Validator
  def self.validate(str)
    new(str).validate
  end

  def initialize(str)
    @str = str
  end

  def validate
    result = Engine.get(@str)

    doc = Nokogiri::HTML(result)
    errors = doc.css("ol > li.error")

    e = errors.map do |error|
      message = error.css("p:first span").text
      locations = error.css("p.location span").map(&:text).map(&:to_i)

      Error.new(message, Location.new(*locations))
    end

    Result.new(e)
  end

  class Result
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def errors?
      errors.size > 0
    end
  end

  class Error
    attr_reader :message, :location

    def initialize(message, location)
      @message = message
      @location = location
    end
  end

  class Location
    include Equalizer.new(:ll, :lc, :rl, :rc)

    attr_reader :ll, :lc, :rl, :rc

    def initialize(ll, lc, rl, rc)
      @ll = ll
      @lc = lc
      @rl = rl
      @rc = rc
    end
  end
end

describe Validator do
  let(:object)        { described_class }
  let(:html_document) { Example1::INVALID_HTML }
  let(:arguments)     { [html_document] }

  context ".validate" do

    subject { object.validate(*arguments) }

    it "indicates if errors are present" do
      subject.errors?.should be_true
    end

    describe "no errors" do
      let(:html_document) { Example1::VALID_HTML }

      it "has no errors" do
        subject.errors?.should be_false
      end
    end

    describe :errors do

      subject { object.validate(*arguments).errors }

      it "has errors" do
        subject.size.should eq(2)
      end

      it "has errors messages" do
        subject.first.message.should eq("Element img is missing required attribute src.")
        subject.last.message.should eq("An img element must have an alt attribute, except under certain conditions. For details, consult guidance on providing text alternatives for images.")
      end

      describe :location do
        it "has errors locations" do
          subject.first.location.should == Validator::Location.new(9, 1, 9, 5)
          subject.first.location.ll.should eq(9)
          subject.first.location.lc.should eq(1)

          subject.first.location.rl.should eq(9)
          subject.first.location.rc.should eq(5)
        end
      end
    end
  end
end

class Validator
  class Engine
    # Use http://validator.nu/ as validator
    def self.get(str)
      data = Curl::PostField.content("content", str)

      c = Curl::Easy.new("http://validator.nu/")
      c.multipart_form_post = true
      c.http_post(data)

      c.body_str
      # e = <<-EOS
      # <!DOCTYPE html>
      # <html lang="en"><head><link href="icon.png" rel="icon"><link href="style.css" rel="stylesheet"><title>Validation results</title></head><body><h1>Validation results</h1><form method="get"><fieldset><legend>Validator Input</legend><table><tbody><tr title="The document to validate."><th><label for="doc">Document</label></th><td><input type="url" name="doc" id="doc" pattern="(?:(?:https?://.+)|(?:data:.+))?" title="Absolute IRI (http, https or data only) of the document to be checked." class="textarea"></td></tr><tr title="Override for transfer protocol character encoding declaration."><th><label for="charset">Encoding</label></th><td><select id="charset" name="charset"><option value="">As set by the server/page</option><option value="UTF-8">UTF-8 (Global)</option><option value="UTF-16">UTF-16 (Global)</option><option value="Windows-1250">Windows-1250 (Central European)</option><option value="Windows-1251">Windows-1251 (Cyrillic)</option><option value="Windows-1252">Windows-1252 (Western)</option><option value="Windows-1253">Windows-1253 (Greek)</option><option value="Windows-1254">Windows-1254 (Turkish)</option><option value="Windows-1255">Windows-1255 (Hebrew)</option><option value="Windows-1256">Windows-1256 (Arabic)</option><option value="Windows-1257">Windows-1257 (Baltic)</option><option value="Windows-1258">Windows-1258 (Vietnamese)</option><option value="ISO-8859-1">ISO-8859-1 (Western)</option><option value="ISO-8859-2">ISO-8859-2 (Central European)</option><option value="ISO-8859-3">ISO-8859-3 (South European)</option><option value="ISO-8859-4">ISO-8859-4 (Baltic)</option><option value="ISO-8859-5">ISO-8859-5 (Cyrillic)</option><option value="ISO-8859-6">ISO-8859-6 (Arabic)</option><option value="ISO-8859-7">ISO-8859-7 (Greek)</option><option value="ISO-8859-8">ISO-8859-8 (Hebrew)</option><option value="ISO-8859-9">ISO-8859-9 (Turkish)</option><option value="ISO-8859-13">ISO-8859-13 (Baltic)</option><option value="ISO-8859-15">ISO-8859-15 (Western)</option><option value="KOI8-R">KOI8-R (Russian)</option><option value="TIS-620">TIS-620 (Thai)</option><option value="GBK">GBK (Chinese, simplified)</option><option value="GB18030">GB18030 (Chinese, simplified)</option><option value="Big5">Big5 (Chinese, traditional)</option><option value="Big5-HKSCS">Big5-HKSCS (Chinese, traditional)</option><option value="Shift_JIS">Shift_JIS (Japanese)</option><option value="ISO-2022-JP">ISO-2022-JP (Japanese)</option><option value="EUC-JP">EUC-JP (Japanese)</option><option value="ISO-2022-KR">ISO-2022-KR (Korean)</option><option value="EUC-KR">EUC-KR (Korean)</option></select></td></tr><tr title="Space-separated list of schema IRIs. (Leave blank to let the service guess.)"><th><label for="schema">Schemas</label></th><td><input name="schema" id="schema" pattern="(?:(?:(?:https?://\S+)|(?:data:\S+))(?:\s+(?:(?:https?://\S+)|(?:data:\S+)))*)?" title="Space-separated list of schema IRIs. (Leave blank to let the service guess.)" value=""></td></tr><tr title="Selecting a preset overrides the schema field above."><th><label for="preset">Preset</label></th><td><select id="preset" name="preset"><option value="">None</option><option value="http://s.validator.nu/html5.rnc http://s.validator.nu/html5/assertions.sch http://c.validator.nu/all/">HTML5 + SVG 1.1 + MathML 3.0</option><option value="http://s.validator.nu/html5-its.rnc http://s.validator.nu/html5/assertions.sch http://c.validator.nu/all/">HTML5 + SVG 1.1 + MathML 3.0 + ITS 2.0</option><option value="http://s.validator.nu/html5-rdfalite.rnc http://s.validator.nu/html5/assertions.sch http://c.validator.nu/all/">HTML5 + SVG 1.1 + MathML 3.0 + RDFa Lite 1.1</option><option value="http://s.validator.nu/xhtml10/xhtml-strict.rnc http://s.validator.nu/html4/assertions.sch http://c.validator.nu/all-html4/">HTML 4.01 Strict + IRI / XHTML 1.0 Strict + IRI</option><option value="http://s.validator.nu/xhtml10/xhtml-transitional.rnc http://s.validator.nu/html4/assertions.sch http://c.validator.nu/all-html4/">HTML 4.01 Transitional + IRI / XHTML 1.0 Transitional + IRI</option><option value="http://s.validator.nu/xhtml10/xhtml-frameset.rnc http://s.validator.nu/html4/assertions.sch http://c.validator.nu/all-html4/">HTML 4.01 Frameset + IRI / XHTML 1.0 Frameset + IRI</option><option value="http://s.validator.nu/xhtml5.rnc http://s.validator.nu/html5/assertions.sch http://c.validator.nu/all/">XHTML5 + SVG 1.1 + MathML 3.0</option><option value="http://s.validator.nu/xhtml5-rdfalite.rnc http://s.validator.nu/html5/assertions.sch http://c.validator.nu/all/">XHTML5 + SVG 1.1 + MathML 3.0 + RDFa Lite 1.1</option><option value="http://s.validator.nu/xhtml1-ruby-rdf-svg-mathml.rnc http://s.validator.nu/html4/assertions.sch http://c.validator.nu/all-html4/">XHTML 1.0 Strict + IRI + Ruby + SVG 1.1 + MathML 3.0</option><option value="http://s.validator.nu/svg-xhtml5-rdf-mathml.rnc http://s.validator.nu/html5/assertions.sch http://c.validator.nu/all/">SVG 1.1 + IRI + XHTML5 + MathML 3.0</option></select></td></tr><tr title="The parser to use. Affects HTTP Accept header."><th><label for="parser">Parser</label></th><td><select id="parser" name="parser"><option value="">Automatically from Content-Type</option><option value="xml">XML; don’t load external entities</option><option value="xmldtd">XML; load external entities</option><option value="html" selected="selected">HTML; flavor from doctype</option><option value="html5">HTML5</option><option value="html4">HTML 4.01 Strict</option><option value="html4tr">HTML 4.01 Transitional</option></select></td></tr><tr title="Space-separated list of namespace URIs."><th><label for="nsfilter"><abbr title="XML namespace">XMLNS</abbr>&nbsp;Filter</label></th><td><input name="nsfilter" id="nsfilter" pattern="(?:.+:.+(?:\s+.+:.+)*)?" title="Space-separated namespace URIs for vocabularies to be filtered out."></td></tr><tr title="Disrespect MIME RFCs."><th></th><td><label for="laxtype"><input type="checkbox" name="laxtype" id="laxtype" value="yes"> Be lax about HTTP Content-Type</label></td></tr><tr title="Display a report about the textual alternatives for images."><th></th><td><label for="showimagereport"><input type="checkbox" name="showimagereport" id="showimagereport" value="yes"> Show Image Report</label></td></tr><tr title="Display the markup source of the input document."><th></th><td><label for="showsource"><input type="checkbox" name="showsource" id="showsource" value="yes" checked="checked"> Show Source</label></td></tr><tr title="Display an outline of the input document."><th></th><td><label for="showoutline"><input type="checkbox" name="showoutline" id="showoutline" value="yes"> Show Outline</label></td></tr><tr><th></th><td><input value="Validate" type="submit" id="submit"></td></tr></tbody></table></fieldset></form><script src="script.js"></script><ol><li class="info"><p><strong>Info</strong>: <span>Using the schema for HTML5 + SVG 1.1 + MathML 3.0 + RDFa Lite 1.1.</span></p></li><li class="error"><p><strong>Error</strong>: <span>Element <a href="http://www.whatwg.org/specs/web-apps/current-work/#the-img-element"><code>img</code></a> is missing required attribute <code>src</code>.</span></p><p class="location"><a href="#l9c5">From line <span class="first-line">9</span>, column <span class="first-col">1</span>; to line <span class="last-line">9</span>, column <span class="last-col">5</span></a></p><p class="extract"><code>d&gt;<span class="lf" title="Line break">↩</span>&lt;body&gt;<span class="lf" title="Line break">↩</span><b>&lt;img&gt;</b><span class="lf" title="Line break">↩</span>&lt;/bod</code></p><dl><dt>Attributes for element <a href="http://www.whatwg.org/specs/web-apps/current-work/#the-img-element"><code>img</code></a>:</dt>
      #      <dd><a href="http://www.whatwg.org/specs/web-apps/current-work/#global-attributes">Global attributes</a></dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-img-alt">alt</a></code> — Replacement text for use when images are not available</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-img-src">src</a></code> — Address of the resource</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-img-srcset">srcset</a></code> — Images to use in different situations (e.g. high-resolution displays, small monitors, etc)</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-img-crossorigin">crossorigin</a></code> — How the element handles crossorigin requests</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-hyperlink-usemap">usemap</a></code> — Name of <a href="http://www.whatwg.org/specs/web-apps/current-work/#image-map">image map</a> to use</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-img-ismap">ismap</a></code> — Whether the image is a server-side image map</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-dim-width">width</a></code> — Horizontal dimension</dd>
      #    <dd><code><a href="http://www.whatwg.org/specs/web-apps/current-work/#attr-dim-height">height</a></code> — Vertical dimension</dd>
      #    </dl></li><li class="error"><p><strong>Error</strong>: <span>An <code>img</code> element must have an <code>alt</code> attribute, except under certain conditions. For details, consult <a href="http://www.w3.org/wiki/HTML/Usage/TextAlternatives" title="About providing text alternatives for images.">guidance on providing text alternatives for images</a>.</span></p><p class="location"><a href="#l9c5">From line <span class="first-line">9</span>, column <span class="first-col">1</span>; to line <span class="last-line">9</span>, column <span class="last-col">5</span></a></p><p class="extract"><code>d&gt;<span class="lf" title="Line break">↩</span>&lt;body&gt;<span class="lf" title="Line break">↩</span><b>&lt;img&gt;</b><span class="lf" title="Line break">↩</span>&lt;/bod</code></p></li></ol><p class="failure">There were errors.</p><h2 id="source">Source</h2><ol class="source"><li id="l1"><code>&lt;!DOCTYPE html&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l2"><code>&lt;html lang='en'&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l3"><code>&lt;head&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l4"><code>&lt;title&gt;Sennheiser: Headphones, Microphones and Wireless Systems&lt;/title&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l5"><code>&lt;meta charset='utf-8'&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l6"><code>&lt;meta content='Headphones, Headsets, Microphones and Wireless Systems - Sennheiser Discover True Sound - www.sennheiser.com' name='description'&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l7"><code>&lt;/head&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l8"><code>&lt;body&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l9"><code><b id="l9c5" class="l9c5">&lt;img&gt;</b></code><code class="lf" title="Line break">↩</code></li><li id="l10"><code>&lt;/body&gt;</code><code class="lf" title="Line break">↩</code></li><li id="l11"><code>&lt;/html&gt;</code></li></ol><p class="stats">Total execution time 4 milliseconds.</p><hr><p><a href="http://about.validator.nu/">About this Service</a> • <a href="http://html5.validator.nu/">Simplified Interface</a></p></body></html>
     # EOS
    end
  end
end
