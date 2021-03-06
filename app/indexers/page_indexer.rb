class PageIndexer

  attr_accessor :page

  def initialize(page)
    @page = page
  end

  def generate_solr_doc(issue_doc)

    full_text = get_full_text(issue_doc, @page.text_link)
    page_id = "#{issue_doc[:id]}-#{@page.sequence}"
    solr_doc = { 
      id: page_id, # @page.id,
      page_no_t:@page.page_no, 
      sequence: @page.sequence,
      text_link: @page.text_link, 
      img_link: @page.img_link, 
      full_text_txt:full_text,
      prev_page_link: nil,
      next_page_link: nil,
      next_page_sequence_label: nil,
      prev_page_sequence_label: nil,
      next_page_label: nil,
      prev_page_label: nil
    }

    current_index = issue_doc[:pages].index { |v| v[0] == @page.id }
    [ :date_issued_display, 
      :issue_no_t,
      :issue_sequence,
      :date_issued_dt, 
      :issue_id_t, 
      :date_issued_link,
      :ht_namespace,
      :ht_barcode,
      :publication_link,
      :publication_label
    ].each do |key|
      solr_doc[key] = issue_doc[key]
    end

    unless current_index - 1 < 0
      solr_doc[:prev_page_link] = issue_doc[:pages][current_index - 1][1]
      solr_doc[:prev_page_sequence_label] = issue_doc[:pages][current_index - 1][2]
      solr_doc[:prev_page_label] = issue_doc[:pages][current_index - 1][3]
    end
    if current_index + 1 < ( issue_doc[:pages].size - 1 )
      solr_doc[:next_page_link] = issue_doc[:pages][current_index + 1][1]
      solr_doc[:next_page_sequence_label] = issue_doc[:pages][current_index + 1][2]
      solr_doc[:next_page_label] = issue_doc[:pages][current_index + 1][3]
    end

    solr_doc
  end

  def index(issue_doc)
    solr_doc = generate_solr_doc(issue_doc)
    conn = Blacklight.default_index.connection
    conn.add solr_doc
  end

  def get_full_text(issue_doc, text_link)
    File.read(Rails.root.join(
      Rails.configuration.text_root, 
      "#{issue_doc[:ht_namespace]}.#{issue_doc[:ht_barcode]}", 
      text_link+'.txt'))
  end

end